# Lead 01 — Re-reported downstream RPC error

## Scenario

Operations calls a downstream service via gRPC (frequently ApiCo, but any service counts). The downstream service errors → raises its own sentry → returns a gRPC status with code `INTERNAL` (or `UNKNOWN`). Operations catches the RPC error and **raises its own sentry**, often including the downstream sentry UUID in the message.

The result is that a single underlying bug produces **two** sentries (one in the downstream service, one in Operations) for every occurrence. The Operations sentry is almost always pure noise — it reports the same thing, usually with less context than the downstream one.

## How to recognize a match

All three must be true:

1. **Top in-repo frame is an RPC call site.** The group's stack trace shows an error coming out of a gRPC client call (`SomeClient::method(...)`, `.call(...)`, etc.) inside Operations code.
2. **The error message references a downstream service error.** Look for phrases like `Sentry: <uuid>`, `INTERNAL_ERROR`, `gRPC status`, or the name of another service. Often the message is literally `"<operation> failed. Sentry: Some(\"<uuid>\")"`.
3. **Reading the call site confirms it.** Open the file at the top in-repo frame and verify that the code is calling an RPC, catching the error, and re-reporting it via `err.report()`, `err_msg!`, `err_ctx!`, or similar — as opposed to doing something genuinely new with the error.

If only (1) and (2) look plausible but (3) shows Operations is doing non-trivial work around the error, this is **not** a match — fall through to the next lead.

## Status-code discrimination — CRITICAL

Groups matching this lead very often contain **a mix of gRPC status codes** (e.g. `13-INTERNAL` and `4-DEADLINE_EXCEEDED`). **They are not equivalent and must not be treated the same way.**

| Status code | Safe to drop silently? | Reason |
|---|---|---|
| `13-INTERNAL` | **Yes** (subject to downstream-verification below) | In our setup, `INTERNAL` is **specifically** the status Stockly services return after catching an unexpected error and raising their own sentry. The server-side sentry UUID is included in the returned `RpcStatus` message (`Sentry: Some("<uuid>")`). This guarantees an upstream sentry exists and is locatable. This is the **only** status for which silent drop is safe. |
| `2-UNKNOWN` | **No** | `UNKNOWN` is NOT a Stockly convention for "server-side failure with a sentry". It is emitted by gRPC runtimes, proxies, load balancers, SDKs, or non-Stockly services that don't follow our convention. It carries **no guarantee** of a sentry UUID and no guarantee the downstream even ran. Keep it and investigate as a separate concern. |
| `4-DEADLINE_EXCEEDED` | **No** | This is almost always a **client-side** timeout. The client gave up waiting; the server may never have finished, may never have started, or may have succeeded without the client knowing. There is **no guarantee** the downstream raised any sentry, and even if it did, the Operations sentry is likely the only signal that the call path is unhealthy. Keep it. Investigate it as a separate concern (network, slow query, retry logic, deadline budget). |
| `14-UNAVAILABLE` | **No** | Transport-level failure (connection refused, pod evicted, load balancer 502). The downstream server process often never received the call, so no downstream sentry exists. Keep it. |
| Other codes (`3-INVALID_ARGUMENT`, `5-NOT_FOUND`, `6-ALREADY_EXISTS`, `9-FAILED_PRECONDITION`, `16-UNAUTHENTICATED`, ...) | **No** | These are **business rejections**, not downstream internal errors. They should be mapped to a typed `Fail` variant on the Operations side (see Case D below), never silently dropped, and never lumped together with INTERNAL. |

**Important:** `INTERNAL` is the **only** droppable status. Do not extend the droppable set to any other code without explicit user direction, even if the code "looks similar".

**Action for mixed-code groups:** split the recommendation by status code. Do not apply a blanket "drop everything" fix. The implementation pattern (see Case B) uses `rpc_failure_handler` to handle only the droppable codes and lets the others propagate unchanged.

## Evidence to collect

Open the file at the top in-repo frame and quote the relevant block. Determine:

1. **Does Operations add any diagnostic info the downstream sentry doesn't already have?**
   Compare what Operations puts in its own sentry (the `err_ctx!` fields, the message, the context chain) against what the downstream service would naturally already have (the arguments it was called with, its own internal state). The downstream sentry already contains:
   - the RPC request (arguments from Operations)
   - everything the downstream function knew about

   Operations therefore only adds value if it logs state that the downstream service does *not* see — e.g. upstream context, loop iteration data, batch identifiers, retry counters, correlation ids specific to Operations.

   If Operations only wraps the error with a message like `"Failed to X. Sentry: <uuid>"` with no additional structured context, the answer is **no added value**.

2. **Is Operations running in a scheduled/looping context, or answering an RPC call?**
   Walk up the call graph from the failing call site until you hit one of:
   - a **gRPC handler** — a function registered as a tonic service method (module usually named `grpc`, file often called after the RPC method, signature like `fn perform(ctx: &RpcContext, req: &XxxRequest) -> InternalResult<RpcResult<XxxRecap>>`) → **RPC-answering mode**
   - a **scheduler entry point** — a `#[scheduled(...)]`, a loop that `sleep`s and re-calls itself, a `main` of a cron binary, a background worker spawned at service start → **scheduled mode**

   One of these two **must** be reachable. If you genuinely cannot decide which it is, say so explicitly in the investigation file (`Recommended action` = `Cannot determine call mode — ask user`) and stop there. Do not guess.

3. **MANDATORY — verify the downstream sentry actually captures the data.** Before recommending "drop silently because downstream has it", you must confirm the downstream sentry exists and contains the expected fields. This is not optional; without it, the recommendation to drop could discard the only surviving signal.

   Procedure:
   - Pick the member issue with the highest count and fetch a recent event via `mcp__sentry__list_issue_events` (with `organizationSlug: "stockly"`, the `issueId`, and `statsPeriod: "14d"`).
   - In that event, find the downstream sentry UUID. It is usually embedded in the error message as `Sentry: Some("<uuid>")` or `sentry_uuid=<uuid>`, or stored in an `err_ctx` field such as `downstream_sentry_uuid`. The Operations sentry title also often contains the UUID (e.g. `RpcFailure 13-INTERNAL ... 0b550707...`).
   - Call `mcp__sentry__get_sentry_resource` with `resourceType: "event"`, `organizationSlug: "stockly"`, `resourceId: "<uuid>"` to fetch the downstream event directly by its UUID. (The tool auto-detects the project, so you do not need to know which downstream project the event lives in.)
   - Verify the downstream event contains: (a) the RPC request payload, (b) any error context Operations was attaching. Quote the relevant fields in the `Evidence` section.
   - If the downstream event **cannot be found** (404, deleted, or the UUID is absent from the Operations event), the droppability conclusion flips: do NOT recommend dropping. Instead, recommend **first** pushing the Operations-side context into the downstream service (via a proto change or by teaching the downstream to report), and only **then** dropping Operations's re-report.
   - Do this verification for `INTERNAL` codes only. For `DEADLINE_EXCEEDED`/`UNAVAILABLE`/business-rejection codes, there is nothing to verify — you are not going to drop them.

## Recommended action (write into the investigation file)

The action depends on the answers above AND the set of status codes present in the group.

### Case A — Operations adds meaningful diagnostic info

**Action:** Try to push that extra info *into the downstream RPC call itself*, so the downstream sentry captures it natively and the Operations sentry becomes redundant.

Ask: could this data (batch id, iteration key, upstream correlation id, caller context, ...) be added as a field on the downstream RPC request proto, or passed via request metadata? If yes:

1. Describe in the investigation file the exact proto change (message name, field name, field type, field number) and the corresponding change in the downstream service to log / attach that field to its own sentry context (via `err_ctx!` or equivalent) — with the specific file and line where the downstream attaches its context.
2. Once that change is made, the group falls back to Case B or Case C — apply the corresponding action on the Operations side.

If the data genuinely cannot be passed downstream (e.g. it only exists as a side effect of Operations-internal state that is not meaningful to the downstream service), leave the current behavior alone. Name *exactly* what Operations adds (quote the context fields) and *why* it cannot be pushed downstream. The underlying fix then belongs in the downstream service and must be described there.

### Case B — Operations adds no value, runs in scheduled mode, group is INTERNAL-only (or INTERNAL+UNKNOWN)

**Action:** Drop `INTERNAL` silently at the Operations call site using the `rpc_failure_handler` pattern. **Do not convert the call site to plain `match` on `grpc::Error`** — the handler pattern is the project convention and composes cleanly if more codes need to be handled later.

The `rpc_failure_handler` trait lives at `lib/rust/grpc_helpers/Client/src/rpc_failure_handler.rs`. Minimal shape:

```rust
use grpc_helpers_core::grpcio::RpcStatusCode;
use grpc_helpers_client::rpc_failure_handler::GrpcResultUtilities;

// Local Fail type for "the downstream already reported this internally, skip it".
// Carries no data — the downstream sentry has everything.
enum CallFail {
    DownstreamReportedInternally,
}

let recap = try_or_wrap!(
    client
        .register_tracking_info(&request)
        .rpc_failure_handler()
        .handle(RpcStatusCode::INTERNAL, |_| CallFail::DownstreamReportedInternally)
        .handle(RpcStatusCode::UNKNOWN,  |_| CallFail::DownstreamReportedInternally)
        .result()
        .err_ctx(&err_ctx)? // still propagate *transport* errors (UNAVAILABLE, DEADLINE_EXCEEDED, ...)
);
// then, where the inner Fail is handled:
match call_result {
    Ok(recap) => /* use recap */,
    Err(CallFail::DownstreamReportedInternally) => /* log at debug and continue/skip this item */,
}
```

Key points the investigation file must include:

1. **Exact file and lines to change** (e.g. `transmit_tracking_info.rs:100-106`).
2. **Before/after snippet** showing the replaced call. Keep the `err_ctx` / `err_tag` attachments on the outer `?` — they still enrich the transport-error case. Only the INTERNAL branch is silenced.
3. **The `Fail` variant introduced**, its module, and whether an existing `Fail` in the file should be reused or a new one created.
4. **Every caller of the function** that contains the patched call, listed with file:line. For each caller, say explicitly whether it must change or not. If a caller raises its own sentry on the propagated error, that caller must be patched in the same way (apply the same lead recursively) or the drop will be silently reintroduced one level up.
5. **Any scheduled retry guarantee.** Confirm by reading the loop (not by asserting) that the background worker will retry the skipped item on the next tick. Quote the relevant loop code in `Evidence`.

### Case C — Operations adds no value, itself answers an RPC call, group is INTERNAL-only

**Action:** Forward the downstream sentry UUID to Operations' own caller instead of raising a new sentry. This means:

1. Add (or reuse) a `Fail` variant on the Operations function carrying the downstream sentry UUID. Concrete current examples (verified at authoring time by the skill author):
   - **Proto-level:** `TechTasks/src/grpc/admin/admin.proto:164` — `OnHoldReasonTaskExtractionFail { string reason = 1; string sentry_uuid = 2; }`
   - **Rust usage:** `TechTasks/src/grpc/admin/close_github_prs.rs:43-49` (obtain the uuid via `err.report()` then put it in the proto Fail) and `TechTasks/src/grpc/admin/process_on_hold_reason_extraction.rs:129-140` (carry the uuid through the Rust `Fail` enum into the proto response).
   - If these files have drifted since, grep for `sentry_uuid` in `.proto` files and `.report()` + `sentry_uuid` in `.rs` files to find a current example. If no current example exists, say so in the investigation and note that the forwarding pattern must be designed fresh — the user will want to review.
2. Use `rpc_failure_handler().handle(RpcStatusCode::INTERNAL, |rpc_status| Fail::DownstreamInternal { sentry_uuid: extract_uuid(rpc_status.message()) })` at the call site. Provide the `extract_uuid` logic inline (a regex or substring match on `Sentry: Some("...")`).
3. Extend `From<Fail> for RpcStatus` (or equivalent) at the Operations RPC handler boundary to propagate the forwarded UUID (include it in the status details/metadata) instead of calling `.report()` itself.
4. Upstream callers of the Operations RPC will then see the downstream sentry UUID in their failure and can decide what to do, instead of a second duplicate sentry being raised at the Operations layer.

Name the Operations function and its `Fail` enum (file:line), the RPC handler at the boundary (file:line), and quote the relevant example from the codebase in `Evidence`.

### Case D — Mixed status codes in the group

**Action:** Split the recommendation. For each status code family:

- **`INTERNAL` / `UNKNOWN`** → apply Case B or C (depending on call mode). State the exact subset of member issues covered.
- **`DEADLINE_EXCEEDED`** → **DO NOT drop.** This is a separate investigation. Write, in the `Recommended action`, a short sub-plan:
  1. Confirm whether the deadline is set by Operations or inherited from the incoming RPC context. Read the call site's deadline/timeout plumbing and quote it.
  2. Measure p50/p95/p99 of the downstream RPC (via Sentry spans or the downstream service's own metrics) and compare against the current deadline.
  3. Depending on findings: either bump the deadline (justified), fix the slow path on the downstream, or add a typed `Fail::Timeout` variant so the caller can handle it without a sentry.
  4. Until that is resolved, keep the current sentry — it is the only signal of the unhealthy path.
- **`UNAVAILABLE`** → **DO NOT drop.** Same reasoning: the downstream may never have received the call. Recommend adding retry-with-backoff for transient UNAVAILABLE (with a cap) and keeping the sentry for persistent cases, OR mapping to a typed `Fail::DownstreamUnavailable` and letting the scheduled loop retry.
- **Business-rejection codes (`INVALID_ARGUMENT`, `NOT_FOUND`, `FAILED_PRECONDITION`, ...)** → these indicate an Operations-side bug or stale state. Map each to a dedicated `Fail` variant on the Operations function and handle it explicitly (escalate, block the item, alert the business owner). **Never** silently drop a business rejection.

The `rpc_failure_handler` pattern composes naturally: chain multiple `.handle(RpcStatusCode::X, ...)` calls, one per code you want to intercept, and let anything else propagate as a transport error.

Every split the investigation makes must identify which member Sentry issues fall into which bucket (by looking at their distinct titles — the status code is visible in the title).

## Output hint

When writing the investigation file's `Matched lead` field, use: `01-re-reported-downstream-rpc`. If the group is mixed-code and only part of it matches (e.g. the INTERNAL subset), write: `01-re-reported-downstream-rpc (partial — <code> subset only)`.
