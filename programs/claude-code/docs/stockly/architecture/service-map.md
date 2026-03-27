# Service Map

How Stockly services relate to each other. Arrows indicate gRPC dependency direction (caller → callee).

## Core Services

### operations (the hub)

The largest and most central service. Manages the full order lifecycle: order registration, purchase submission to suppliers, shipping coordination, cancellations, refunds, problems, and after-sale workflows.

**Depends on:** stocks (pricing, item data), shipments (parcel tracking, addresses), invoices, repackages, files (upload/PDF), auths (entity management), buckets (notifications), supply_messages, backoffice (manually tracked workflows)

**Depended on by:** integrations (via demand/supply gRPC), backoffice, consumer_backoffice

**Key gRPC services defined:**
- `Demand` — retailer-facing: register orders, cancellations, messages, refunds
- `Supply` — supplier-facing: tracking info, purchase workflows
- `Admin` — internal management RPCs
- `Backoffice` / `ConsumerBackoffice` — admin UI endpoints
- `Orders`, `Purchases`, `Problems`, `Bindings`, `ReturnLabels` — domain-specific

### stocks

Manages stock levels, pricing, and item registration. Suppliers register item availability and pricing; stocks computes answers (prices to offer retailers).

**Key gRPC services:** `Register` (item/shipping contract registration), `Items`, `Retailers`, `Basics`

**Depends on:** auths

### auths

Authentication and authorization. Manages entities (retailers, suppliers, demanders) and their permissions.

**Depended on by:** most services (via `auths_helpers`)

### shipments

Parcel tracking, carrier management, shipping addresses. Provides parcel lifecycle data to operations.

**Key gRPC services:** `Parcels`, `Addresses`, `Carriers`, `Notifications`

### invoices

Invoice generation, rendering, and management.

### supply_messages

Messages exchanged between Stockly and suppliers about purchases. Has both a gRPC API and a CLI tool (`src/cli.rs`).

### repackages

Repackaging workflows when items need regrouping before shipping.

### files

File storage service (upload, PDF generation, access tokens).

### Buckets

Notification bucket system.

## Integration Layer

### integrations/

Contains **400+ retailer/supplier connectors** — each in its own subdirectory (e.g., `integrations/zalando/`, `integrations/amazon/`). Connectors translate between retailer-specific APIs and Stockly's operations gRPC interface (Demand/Supply).

Each connector typically has:
- `ApiConnector/` — Rust crate that speaks the retailer's API
- `lib/Sdk/` — SDK wrapping the retailer's REST/SOAP API
- `ShippingBoApp/` / `ShopifyApp/` — platform-specific apps (some connectors)

## Admin & Backoffice

### backoffice

Admin interface for Stockly ops team. Manages orders, retailer configuration, manually tracked workflows.

### consumer_backoffice

Consumer-facing backoffice — order tracking, cancellation requests, delivery disputes from the end-consumer perspective.

### supply_backoffice

Supplier-facing admin interface.

## Supporting Services

| Service | Purpose |
|---------|---------|
| `destockers` | Destocker (outlet) management |
| `search` | Search functionality |
| `EnvService` | Environment variable service |
| `DemanderIntegrationTracker` | Tracks demander integration status |
| `SupplierIntegrationTracker` | Tracks supplier integration status |
| `TaskTracker` | Task tracking service |
| `TechTasks` | Technical task management |
| `SftpHealthChecker` | SFTP connectivity monitoring |

## Data Flow (simplified)

```
Retailer API ──► integrations (ApiConnector)
                    │
                    ▼ (Demand gRPC)
               operations ◄──► stocks (pricing)
                    │              │
                    ├──► shipments (parcels)
                    ├──► invoices
                    ├──► supply_messages
                    ├──► repackages
                    ├──► files (PDFs, uploads)
                    └──► auths (entity mgmt)
                    │
                    ▼ (Supply gRPC)
               integrations (ApiConnector) ──► Supplier API
```
