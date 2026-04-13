# Lead 02 — High-volume unactionable warning (sample instead of drop)

## Scenario

Operations reports a sentry that flags a condition **outside our control** — typically an external partner's delayed or unexpected data. The sentry is useful as a signal (nobody else reports this condition), but at current volume it floods Sentry with thousands of events per day.

The right fix is **not** to delete the sentry (we'd lose the signal) and **not** to keep it as-is (alert fatigue). Instead, apply **time-based sampling** so the sentry fires at most once per interval, preserving visibility while cutting volume by 80–99%.

## How to recognize a match

All four must be true:

1. **Not a re-reported downstream error.** The sentry originates in Operations code, not from catching and re-reporting a downstream RPC failure. If it's a re-report, use lead 01 instead.
2. **The flagged condition is outside our control.** Operations is a passive receiver (e.g., an external partner sends late data). We cannot fix the root cause; we can only observe it.
3. **High volume with no actionable follow-up.** The sentry fires >1000 times per 14d window, and there is no evidence (PRs, incident responses, runbooks) that anyone has ever acted on individual occurrences.
4. **Not reported by another service.** No downstream or upstream service already captures this same condition. If another service does, deletion is preferable to sampling.

**Strong signal:** `err_msg(...).with_level(sentry::Level::Warning).report()` with no control-flow effect is almost always a match. But the pattern also applies to `bail!` / `InternalError` paths if the error is fundamentally unactionable external noise — in that case the recommended action includes converting the hard error to a sampled warning (since a `bail!` that nobody can act on is a misclassified warning).

If condition 1 fails → lead 01.
If condition 2 fails (we can fix it) → fix the root cause instead.
If condition 3 fails (low volume) → leave the sentry as-is; it's not flooding.
If condition 4 fails (reported elsewhere) → delete instead of sampling.

## Evidence to collect

1. **Quote the reporting block.** Show the code that raises the sentry (whether `.report()`, `bail!`, or `?` propagation) with file:line.
2. **Classify the reporting mechanism.** Is it already a pure-telemetry `.report()` with no control-flow effect, or is it a `bail!`/`InternalError` that aborts execution? If the latter, the recommended action must include converting it to a non-aborting sampled warning (see below).
3. **Confirm the condition is external.** Identify who triggers the condition (partner API, retailer pipeline, etc.) and confirm Operations has no ability to prevent it.
4. **Check that no other service reports the same condition.** If a downstream or upstream service already captures this signal, deletion is preferable to sampling.
5. **Note the current volume** (from the Sentry issue counts) and compute the expected post-sampling volume at the recommended interval.

## Recommended action — apply time-based sampling

### The pattern

Use double-checked locking with `parking_lot::RwLock<Option<std::time::Instant>>` to limit reports to at most once per `MIN_INTERVAL`. This is the established project pattern — existing usages:

- `lib/rust/DieselHelpers/src/instrumentation.rs:289-305` (span tracking warnings, 60s)
- `operations/Service/src/grpc/demand/register_order_line_cancellation.rs:29-54` (late cancellation warnings, 60s)

### Code template

```rust
if <condition_that_fires_too_often> {
    // <Explain why this interval was chosen and the approximate volume reduction>
    const MIN_INTERVAL: std::time::Duration = std::time::Duration::from_secs(60);
    static LAST_REPORTED_AT: parking_lot::RwLock<Option<std::time::Instant>> = parking_lot::RwLock::new(None);
    fn should_sample(last_reported_at: &Option<std::time::Instant>) -> bool {
        last_reported_at.is_none_or(|t| t.elapsed() > MIN_INTERVAL)
    }
    let last_reported_at_read_guard = LAST_REPORTED_AT.read();
    let should_report = if should_sample(&last_reported_at_read_guard) {
        drop(last_reported_at_read_guard);
        let mut last_reported_at_write_guard = LAST_REPORTED_AT.write();
        if should_sample(&last_reported_at_write_guard) {
            *last_reported_at_write_guard = Some(std::time::Instant::now());
            true
        } else {
            false
        }
    } else {
        false
    };
    if should_report {
        err_msg("...")
            .with_ctx_ser(...)
            .with_level(sentry::Level::Warning)
            .report();
    }
}
```

### Key details for the investigation file

1. **Named constant with rationale comment.** `MIN_INTERVAL` must have a comment explaining why that duration was chosen and the expected volume reduction (e.g., "60s → ~800/day instead of ~4k/day").
2. **Double-checked locking correctness.** The read guard is checked first (cheap, no contention). Only if sampling is due, the read guard is explicitly `drop`ped before acquiring the write guard. The inner re-check ensures only one thread per interval reports — `true` is returned **only inside the inner check**, not unconditionally from the outer branch.
3. **No new dependencies.** `parking_lot` is available transitively; `std::time::Instant` and `std::time::Duration` are stdlib.
4. **Each sampling site needs its own `static`.** If the same file has multiple independent warnings, each gets its own `LAST_REPORTED_AT`.

### When the sentry is a `bail!` / `InternalError` (not already a `.report()`)

If the sentry currently aborts execution (`bail!`, `?` propagation, `return Err(...)`) but the condition is genuinely unactionable external noise, the recommended action has **two parts**:

1. **Convert the hard error to a non-aborting path.** Remove the `bail!` / early return so execution continues (the condition is not a real error — it's a misclassified warning). Describe exactly what the control flow should do instead (skip the item, continue the loop, return a default, etc.).
2. **Add the sampling guard** around a `.report()` call at the former `bail!` site, using the template above.

The investigation file must include both parts with before/after snippets. Caller changes may be needed if removing the error path changes the function signature or `Fail` enum.

### What the investigation file must include

1. **Exact file and lines** of the reporting block to wrap (or convert + wrap).
2. **Before/after snippet** showing the original code and the sampled version.
3. **The chosen interval** with justification (default: 60s unless the volume warrants something different).
4. **Import changes** — verify whether `parking_lot` needs to be added to the file's imports (usually not, since it's used via full path `parking_lot::RwLock`). Check if any existing imports become unused after the edit.
5. **Caller changes** — if the reporting mechanism was a `bail!`/`InternalError` that's being converted to a non-aborting sampled warning, check whether callers need updating (changed return type, removed `Fail` variant, etc.). If it was already a pure `.report()`, no caller changes are needed.

## Output hint

When writing the investigation file's `Matched lead` field, use: `02-high-volume-unactionable-warning`.
