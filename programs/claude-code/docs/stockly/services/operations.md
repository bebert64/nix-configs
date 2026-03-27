# Operations Service

The largest and most central service. Manages the full order lifecycle from registration through after-sale.

## Crate Structure

| Crate | Package name | Purpose |
|-------|-------------|---------|
| `operations/Service/` | `operations` | Main binary — gRPC server, business logic |
| `operations/Core/` | `operations_core` | Shared types, IDs, lightweight structs (feature-gated `schema` for Diesel) |
| `operations/Schema/` | `operations_schema` | Diesel schema, SQL types, migrations |
| `operations/MismatchDetection/` | — | Data consistency checks (deployment tool) |
| `operations/Service/post_deployment_tests/` | `operations_post_deployment_tests` | Post-deploy smoke tests |

Additionally, ~45 sub-crates under `Service/src/` for domain modules and proto crates.

## Entry Point

`main.rs` initializes Sentry, spawns an OpenMetrics HTTP server, then runs the gRPC server via `operations::build_server().run_and_await_ctrlc_then_close()`.

`lib.rs` declares all modules and defines a prelude with common imports (`internal_error::*`, `operations_core::prelude::*`, `serde`, `auths_helpers::EntityId`).

## Module Layout

| Module | Domain |
|--------|--------|
| `demand/` | Retailer-facing order registration, cancellations, messages, refunds, delivery disputes |
| `supply/` | Supplier-facing purchase submission, tracking, cancellations, delivery disputes |
| `matchings/` | Order-line to purchase matching logic |
| `messages/` | Order messages (automated and manual) |
| `problems/` | Problem reporting and resolution |
| `parcels/` | Parcel item tracking within operations context |
| `snoozes/` | Deferred action scheduling |
| `retailers/` | Retailer configuration and management |
| `backoffice/` | Internal admin RPCs |
| `consumer_backoffice/` | Consumer-facing RPCs |
| `grpc/` | All gRPC handler implementations |
| `schedule.rs` | Cron-based scheduled jobs |

Sub-crates extracted from Service for reuse:
- `operations_cancellations`, `operations_claims`, `operations_refunds`
- `operations_shipments_parcels`, `operations_return_labels`
- `operations_addresses`, `operations_location`
- `operations_stocks`, `operations_invoices`
- `operations_demand_messages`, `operations_messages_ai`
- `operations_interning`, `operations_mismatch_detection`
- `operations_matchings`, `operations_backoffice_olaop`

## gRPC Services

All proto files live in `Service/src/grpc/<service_name>/<service_name>.proto`.

| Service | Package | Purpose |
|---------|---------|---------|
| `Demand` | `demand` | Retailer integration: register orders, cancellations, messages, refunds |
| `Supply` | `supply` | Supplier integration: tracking info, purchase workflows |
| `Admin` | `admin` | Internal management (bulk operations, config) |
| `Backoffice` | `backoffice` | Admin UI endpoints |
| `ConsumerBackoffice` | `consumer_backoffice` | Consumer-facing endpoints |
| `Orders` | `orders` | Order queries and management |
| `Purchases` | `purchases` | Purchase lifecycle management |
| `Problems` | `problems` | Problem reporting |
| `Bindings` | `bindings` | Order-line ↔ purchase binding management |
| `ReturnLabels` | `return_labels` | Return label generation |
| `Retailers` | `retailers` | Retailer config management |
| `ShipmentsNotifications` | — | Inbound notifications from shipments service |
| `RepackagesNotifications` | — | Inbound notifications from repackages service |

## Database

Schema in `operations/Schema/src/schema.rs` — very large (hundreds of tables). Key table families:

- `orders`, `order_lines`, `order_messages` — order data
- `purchases`, `purchases_submissions`, `purchases_shippings` — purchase lifecycle
- `purchase_cancellations`, `purchase_cancellation_decisions` — cancellation workflow
- `refunds`, `order_line_refunds`, `shipping_refunds` — refund tracking
- `problems`, `problem_tags` — issue management
- `retailers`, `retailer_groups` — retailer configuration
- `addresses` — shipping/billing addresses
- `parcel_items` — parcel contents tracking

Many custom SQL types (enums) defined in `sql_types` module for domain concepts like `AcceptedRefusedOrAborted`, `BuyerCancellationReason`, `PaymentMethod`, etc.

## Key External Dependencies

Proto crates from other services: `auths_proto_entities`, `stocks_proto_*`, `shipments_proto_*`, `invoices_proto_invoices`, `repackages_proto_*`, `supply_messages_proto_*`, `buckets_proto_notifications`, `files_sdk_*`.

Stockly libs heavily used: `grpc_helpers_server`, `diesel_helpers`, `internal_error`, `model_id`, `validation`, `chrono_helpers`, `price`, `countries`.
