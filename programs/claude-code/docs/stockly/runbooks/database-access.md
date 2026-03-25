# Database access for investigations

When you need a Stockly database URI (e.g. for investigating Quality Tech tickets, debugging, or ad-hoc queries), obtain it on demand via SOPS. Do not store it in clear in config or code.

## Layout (SOPS)

URIs are stored encrypted in the user nix-configs SOPS under `stockly.dbs.<service>`. One URI per service:

| Secret key | Service / DB |
|------------|---------------|
| `stockly/dbs/operations` | Operations (core workflows, orders, after-sale) |
| `stockly/dbs/backoffice` | Backoffice |
| `stockly/dbs/stocks` | Stocks (pricing, offers) |
| `stockly/dbs/shipments` | Shipments |
| `stockly/dbs/invoices` | Invoices |
| `stockly/dbs/buckets` | Buckets |
| `stockly/dbs/files` | Files |
| `stockly/dbs/repackages` | Repackages |
| `stockly/dbs/supply-messages` | Supply Messages |

## How to get a URI

In a shell where the user environment is loaded, run:

```bash
sops-read stockly/dbs/<service>
```

Example: `sops-read stockly/dbs/operations` for the operations DB.

Use the output only in memory or for the current session (e.g. pass to psql, a script, or an env var in a one-off command). Do not write it to a file under the repo or to any config that gets committed.

## Rules

- Never commit or suggest committing the decrypted URI.
- Prefer running read-only or scoped queries when possible.
