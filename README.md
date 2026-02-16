# ContractorHub

A global contractor management API built with Elixir and Phoenix. Manage contractors, contracts, and compliance across 8 countries through a RESTful JSON API.

## Tech Stack

- **Elixir 1.16** / **OTP 26** — functional, fault-tolerant backend
- **Phoenix 1.8** — web framework
- **PostgreSQL 15** — primary database
- **OpenAPI 3.0** — auto-generated interactive docs
- **Docker** — containerized deployment
- **Fly.io** — production hosting

## Features

- **Multi-tenancy** — all resources scoped by company via API key
- **Contractor lifecycle** — `pending` -> `active` -> `offboarded` state machine
- **Contract lifecycle** — `draft` -> `active` -> `completed` / `terminated` state machine
- **Country-specific compliance** — tax ID validation, payment methods, and currency rules for 8 countries (US, GB, DE, NL, BR, CA, SG, ID)
- **Audit logging** — every state change recorded with actor, action, and diff
- **Cursor-based pagination** — efficient traversal of large datasets
- **OpenAPI / Swagger UI** — interactive API documentation at `/api/docs`

## Prerequisites

- Elixir ~> 1.15
- Erlang/OTP 26+
- PostgreSQL 15

Or just Docker for the database:

```bash
docker compose up -d   # starts PostgreSQL
```

## Getting Started

```bash
# Clone the repo
gh repo clone sraihandzaky/contractor_hub && cd contractor_hub

# Install dependencies, create DB, run migrations, seed data, install git hooks
mix setup

# Start the server
mix phx.server
```

The API is available at `http://localhost:4000`. Seed data creates a demo company with a test API key:

```bash
curl http://localhost:4000/api/v1/health

curl -H "Authorization: Bearer chub_sk_demo_acme_2025" \
  http://localhost:4000/api/v1/contractors
```

Interactive docs are at `http://localhost:4000/api/docs`.

## Environment Variables

| Variable          | Required | Default | Description                           |
| ----------------- | -------- | ------- | ------------------------------------- |
| `DATABASE_URL`    | prod     | —       | PostgreSQL connection URL             |
| `SECRET_KEY_BASE` | prod     | —       | Phoenix secret (`mix phx.gen.secret`) |
| `PHX_HOST`        | prod     | —       | Public hostname                       |
| `PORT`            | no       | `4000`  | HTTP port                             |
| `POOL_SIZE`       | no       | `10`    | DB connection pool size               |
| `ECTO_IPV6`       | no       | —       | Enable IPv6 for DB connections        |

## API Overview

Base URL: `/api/v1`

### Public (no auth)

| Method | Path         | Description                                 |
| ------ | ------------ | ------------------------------------------- |
| `GET`  | `/health`    | Health check                                |
| `POST` | `/companies` | Register company (returns API key)          |
| `GET`  | `/countries` | List supported countries & compliance rules |

### Protected (Bearer token)

**Companies**

| Method  | Path            | Description                 |
| ------- | --------------- | --------------------------- |
| `GET`   | `/companies/me` | Get current company profile |
| `PATCH` | `/companies/me` | Update company profile      |

**Contractors**

| Method  | Path                        | Description                              |
| ------- | --------------------------- | ---------------------------------------- |
| `GET`   | `/contractors`              | List contractors (paginated, filterable) |
| `POST`  | `/contractors`              | Create contractor                        |
| `GET`   | `/contractors/:id`          | Get contractor details                   |
| `PATCH` | `/contractors/:id`          | Update contractor                        |
| `POST`  | `/contractors/:id/activate` | Activate contractor                      |
| `POST`  | `/contractors/:id/offboard` | Offboard contractor                      |

**Contracts**

| Method  | Path                       | Description                            |
| ------- | -------------------------- | -------------------------------------- |
| `GET`   | `/contracts`               | List contracts (paginated, filterable) |
| `POST`  | `/contracts`               | Create contract                        |
| `GET`   | `/contracts/:id`           | Get contract details                   |
| `PATCH` | `/contracts/:id`           | Update contract                        |
| `POST`  | `/contracts/:id/activate`  | Activate contract                      |
| `POST`  | `/contracts/:id/complete`  | Complete contract                      |
| `POST`  | `/contracts/:id/terminate` | Terminate contract                     |

**Audit Logs**

| Method | Path          | Description                                                        |
| ------ | ------------- | ------------------------------------------------------------------ |
| `GET`  | `/audit-logs` | List audit logs (filterable by resource_type, resource_id, action) |

### Documentation

| Method | Path           | Description           |
| ------ | -------------- | --------------------- |
| `GET`  | `/api/openapi` | OpenAPI 3.0 JSON spec |
| `GET`  | `/api/docs`    | Swagger UI            |

## Authentication

1. Register a company via `POST /api/v1/companies`
2. Receive an API key prefixed with `chub_sk_`
3. Include it in all subsequent requests:

```
Authorization: Bearer chub_sk_<your_key>
```

Keys are hashed (SHA-256) before storage. The raw key is only shown once at registration.

## Running Tests

```bash
mix test              # run test suite
mix test --cover      # with coverage report (80% threshold)
mix precommit         # compile (warnings-as-errors) + format + credo + test
```

## Deployment

### Docker

```bash
docker build -t contractor_hub .
docker run -p 4000:4000 \
  -e DATABASE_URL="ecto://user:pass@host/db" \
  -e SECRET_KEY_BASE="$(mix phx.gen.secret)" \
  -e PHX_HOST="example.com" \
  contractor_hub
```

### Fly.io

The project includes `fly.toml` (region: `sin`) and a GitHub Actions workflow that deploys on version tags:

```bash
fly secrets set DATABASE_URL="postgres://..." SECRET_KEY_BASE="..."
fly deploy

# or push a tag to trigger CI/CD:
git tag v0.1.0 && git push --tags
```

## Project Structure

```
lib/
├── contractor_hub/              # Core business logic
│   ├── auth/                    # API key generation & verification
│   ├── companies/               # Company schema (soft-delete)
│   ├── contractors/             # Contractor CRUD & status FSM
│   ├── contracts/               # Contract CRUD & lifecycle FSM
│   ├── compliance/              # Country rules (8 countries)
│   ├── audit/                   # Audit log schema & queries
│   ├── scope.ex                 # Multi-tenant query scoping
│   ├── filters.ex               # Composable query filters
│   ├── paginator.ex             # Cursor-based pagination
│   └── sorting.ex               # Query sorting
│
└── contractor_hub_web/          # API layer
    ├── controllers/             # Request handling & JSON views
    ├── plugs/                   # Auth middleware
    ├── schemas/                 # OpenAPI schema definitions
    ├── router.ex                # Route definitions
    └── api_spec.ex              # OpenAPI 3.0 spec
```
