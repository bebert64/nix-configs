---
description: "Make a gRPC call to a Stockly service. Use when the user asks to call, query, or invoke a gRPC RPC on a Stockly service (operations, stocks, shipments, etc.)."
---

# Call Stockly gRPC Service

Make a gRPC request to a Stockly production service using `grpcurl` via `nix-shell`.

## Service addresses (prod)

| Service          | Address                                        |
|------------------|-------------------------------------------------|
| auths            | `grpcs://auths.prod.stockly.tech:4011`          |
| destockers       | `grpcs://destockers.prod.stockly.tech:4025`     |
| files            | `grpcs://files.prod.stockly.tech:4017`          |
| invoices         | `grpcs://invoices.prod.stockly.tech:4006`       |
| operations       | `grpcs://operations.prod.stockly.tech:4005`     |
| repackages       | `grpcs://repackages.prod.stockly.tech:4002`     |
| search-auths     | `grpcs://search-auths.prod.stockly.tech:4020`   |
| search-ingestion | `grpcs://search-ingestion.prod.stockly.tech:4021`|
| shipments        | `grpcs://shipments.prod.stockly.tech:4003`      |
| stocks           | `grpcs://stocks.prod.stockly.tech:4000`         |
| supply-messages  | `grpcs://supply-messages.prod.stockly.tech:4010` |
| task-tracker     | `grpcs://task-tracker.prod.stockly.tech:4004`   |

## TLS certificates

- CA cert: `~/certificates/ca-prod.pem`
- Client cert: `~/certificates/romain_prod_client_chain.crt`
- Client key: `~/certificates/romain_prod_client.key`

## Finding proto files

Proto files live in the Stockly monorepo at `$STOCKLY_WORKTREE_ROOT`. The layout follows these patterns:

- **Service gRPC protos**: `<service>/Service/src/grpc/<module>/<module>.proto`
  - e.g. `operations/Service/src/grpc/backoffice/backoffice.proto`
- **Service shared protos** (types, basics): `<service>/Service/src/protos/<name>.proto`
  - e.g. `operations/Service/src/protos/operations_basics.proto`, `stocks/Service/src/protos/stocks_basics.proto`
- **Root shared protos**: `protos/<name>.proto`
  - e.g. `protos/basics.proto`, `protos/demander_take.proto`
- **Standalone services** (no `Service/` subdirectory): `<service>/src/grpc/<module>/<module>.proto`
  - e.g. `TaskTracker/src/grpc/tasks/tasks.proto`, `EnvService/src/grpc/env/env.proto`

To find the right proto for an RPC, use:

```bash
# Find all proto files for a service (e.g. operations)
find "$STOCKLY_WORKTREE_ROOT" -path "*/operations/Service/src/grpc/*/*.proto"

# Search for a specific RPC method name across all protos
grep -r "rpc method_name" "$STOCKLY_WORKTREE_ROOT" --include="*.proto" -l
```

## Resolving proto imports

Proto files import each other with paths relative to `$STOCKLY_WORKTREE_ROOT`. Before calling `grpcurl`, you must collect the target proto **and all its transitive imports**. Steps:

1. Read the target proto and note all `import "..."` lines.
2. For each import, check if the file exists under `$STOCKLY_WORKTREE_ROOT`.
3. Recursively check those files for further imports.
4. Continue until all imports are resolved.

## Making the call

Use `grpcurl` via `nix-shell`:

```bash
nix-shell -p grpcurl --run 'grpcurl \
  -cacert ~/certificates/ca-prod.pem \
  -cert ~/certificates/romain_prod_client_chain.crt \
  -key ~/certificates/romain_prod_client.key \
  -import-path "$STOCKLY_WORKTREE_ROOT" \
  -proto <path/to/service.proto relative to STOCKLY_WORKTREE_ROOT> \
  -d "<json request body>" \
  <host>:<port> \
  <package>.<Service>/<rpc_method>'
```

### Example: query purchase data from operations

```bash
nix-shell -p grpcurl --run 'grpcurl \
  -cacert ~/certificates/ca-prod.pem \
  -cert ~/certificates/romain_prod_client_chain.crt \
  -key ~/certificates/romain_prod_client.key \
  -import-path "$STOCKLY_WORKTREE_ROOT" \
  -proto operations/Service/src/grpc/backoffice/backoffice.proto \
  -d "{\"id\": 2691335, \"id_type\": \"PurchaseId\"}" \
  operations.prod.stockly.tech:4005 \
  backoffice.Backoffice/order_line_and_or_purchase_data'
```

## Process

1. **Identify the service and RPC**: Determine which service to call and what RPC method the user wants.
2. **Find the proto file**: Use the patterns above to locate the correct `.proto` file.
3. **Read the proto**: Open the proto file to find the exact RPC signature, request message type, field names, and enum values.
4. **Resolve imports**: Collect all transitive proto imports so `grpcurl` can parse the schema.
5. **Build the request**: Construct the JSON request body matching the proto message definition.
6. **Execute**: Run the `grpcurl` command with the correct address from the table above.
7. **Present results**: Show the user the response, summarizing key fields if the output is large.
