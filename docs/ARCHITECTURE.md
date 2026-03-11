# Expense & Budget Tracker — Architecture Documentation

## 1. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐                 │
│   │ Android  │    │   iOS    │    │   Web    │                 │
│   │  (APK)   │    │  (IPA)   │    │ (WASM)  │                 │
│   └────┬─────┘    └────┬─────┘    └────┬─────┘                 │
│        │               │               │                        │
│        └───────────┬───┴───────────────┘                        │
│                    │                                            │
│           ┌────────▼────────┐                                   │
│           │  Flutter App    │                                   │
│           │  (Dart)         │                                   │
│           │                 │                                   │
│           │ • Provider      │                                   │
│           │ • go_router     │                                   │
│           │ • fl_chart      │                                   │
│           │ • secure_storage│                                   │
│           └────────┬────────┘                                   │
└────────────────────┼────────────────────────────────────────────┘
                     │  HTTPS / REST API
                     │  JWT Bearer Token
┌────────────────────┼────────────────────────────────────────────┐
│                    │        API GATEWAY                         │
│           ┌────────▼────────┐                                   │
│           │   Nginx / LB    │  ← TLS termination               │
│           │   (Cloud)       │  ← Rate limiting (L7)            │
│           └────────┬────────┘                                   │
└────────────────────┼────────────────────────────────────────────┘
                     │
┌────────────────────┼────────────────────────────────────────────┐
│                    │      BACKEND LAYER                         │
│           ┌────────▼────────┐                                   │
│           │   FastAPI       │                                   │
│           │   (Python 3.11) │                                   │
│           │                 │                                   │
│           │ ┌─────────────┐ │                                   │
│           │ │ Middleware   │ │                                   │
│           │ │ • CORS      │ │                                   │
│           │ │ • Rate Limit│ │                                   │
│           │ │ • Security  │ │                                   │
│           │ │   Headers   │ │                                   │
│           │ └─────────────┘ │                                   │
│           │                 │                                   │
│           │ ┌─────────────┐ │                                   │
│           │ │ Auth Layer  │ │                                   │
│           │ │ • JWT       │ │                                   │
│           │ │ • bcrypt    │ │                                   │
│           │ │ • OAuth2    │ │                                   │
│           │ └─────────────┘ │                                   │
│           │                 │                                   │
│           │ ┌─────────────┐ │      ┌────────────────┐           │
│           │ │ Service     │ │      │                │           │
│           │ │ Layer       │◄├──────┤  SQLAlchemy    │           │
│           │ │             │ │      │  (Async ORM)   │           │
│           │ └─────────────┘ │      └───────┬────────┘           │
│           └─────────────────┘              │                    │
└────────────────────────────────────────────┼────────────────────┘
                                             │
┌────────────────────────────────────────────┼────────────────────┐
│                  DATA LAYER                │                    │
│                                            │                    │
│              ┌─────────────────────────────▼──┐                 │
│              │      PostgreSQL 16              │                 │
│              │                                 │                 │
│              │  ┌───────┐ ┌─────────┐ ┌─────┐ │                 │
│              │  │ users │ │expenses │ │budg- │ │                 │
│              │  │       │ │         │ │ets   │ │                 │
│              │  └───────┘ └─────────┘ └─────┘ │                 │
│              └────────────────────────────────┘                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Folder Structure

```
startup/
├── docker-compose.yml              # Orchestrates DB + API
├── .gitignore
│
├── backend/                         # FastAPI backend
│   ├── Dockerfile
│   ├── pyproject.toml               # Dependencies & tooling
│   ├── alembic.ini                  # DB migration config
│   ├── .env.example                 # Environment template
│   ├── .gitignore
│   │
│   ├── alembic/                     # Database migrations
│   │   ├── env.py
│   │   ├── script.py.mako
│   │   └── versions/
│   │
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                  # App factory + middleware
│   │   │
│   │   ├── core/                    # Core infrastructure
│   │   │   ├── config.py            # Settings from env vars
│   │   │   ├── database.py          # Async engine + session
│   │   │   ├── security.py          # JWT + password hashing
│   │   │   └── deps.py              # FastAPI dependencies
│   │   │
│   │   ├── models/                  # SQLAlchemy ORM models
│   │   │   ├── user.py
│   │   │   ├── expense.py
│   │   │   └── budget.py
│   │   │
│   │   ├── schemas/                 # Pydantic request/response
│   │   │   ├── auth.py
│   │   │   ├── user.py
│   │   │   ├── expense.py
│   │   │   ├── budget.py
│   │   │   └── summary.py
│   │   │
│   │   ├── services/                # Business logic layer
│   │   │   ├── auth_service.py
│   │   │   ├── expense_service.py
│   │   │   ├── budget_service.py
│   │   │   └── summary_service.py
│   │   │
│   │   └── api/                     # Route handlers
│   │       └── v1/
│   │           ├── router.py        # Aggregated v1 router
│   │           ├── auth.py
│   │           ├── expenses.py
│   │           ├── budgets.py
│   │           └── summary.py
│   │
│   └── tests/
│       └── __init__.py
│
└── frontend/                        # Flutter mobile + web
    ├── pubspec.yaml
    ├── analysis_options.yaml
    └── lib/
        ├── main.dart
        │
        ├── core/                    # App-wide config
        │   ├── api_config.dart
        │   ├── api_client.dart
        │   ├── theme.dart
        │   └── router.dart
        │
        ├── models/                  # Data models
        │   ├── user_model.dart
        │   ├── expense_model.dart
        │   └── budget_model.dart
        │
        ├── providers/               # State management
        │   ├── auth_provider.dart
        │   ├── expense_provider.dart
        │   └── budget_provider.dart
        │
        └── screens/                 # UI screens
            ├── auth/
            │   ├── login_screen.dart
            │   └── register_screen.dart
            ├── home/
            │   └── home_screen.dart
            ├── expenses/
            │   ├── expense_list_screen.dart
            │   └── add_expense_screen.dart
            ├── budget/
            │   └── budget_screen.dart
            ├── summary/
            │   └── summary_screen.dart
            └── settings/
                └── settings_screen.dart
```

---

## 3. Database Schema

```sql
-- Users
CREATE TABLE users (
    id          VARCHAR(36)     PRIMARY KEY,
    email       VARCHAR(255)    NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_users_email ON users(email);

-- Expenses
CREATE TABLE expenses (
    id           VARCHAR(36)     PRIMARY KEY,
    user_id      VARCHAR(36)     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount       NUMERIC(12,2)   NOT NULL,
    category     VARCHAR(100)    NOT NULL,
    note         TEXT,
    date_created TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_date ON expenses(date_created);

-- Budgets (one per user)
CREATE TABLE budgets (
    id             VARCHAR(36)     PRIMARY KEY,
    user_id        VARCHAR(36)     NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    daily_budget   NUMERIC(12,2)   NOT NULL DEFAULT 0,
    weekly_budget  NUMERIC(12,2)   NOT NULL DEFAULT 0,
    monthly_budget NUMERIC(12,2)   NOT NULL DEFAULT 0
);
CREATE INDEX idx_budgets_user_id ON budgets(user_id);
```

### Entity Relationship Diagram

```
┌──────────┐       1:N        ┌───────────┐
│  users   │──────────────────│ expenses  │
│          │                  │           │
│ id (PK)  │                  │ id (PK)   │
│ email    │                  │ user_id   │→ FK
│ hashed_  │                  │ amount    │
│ password │                  │ category  │
│ created_ │                  │ note      │
│ at       │                  │ date_     │
└─────┬────┘                  │ created   │
      │                       └───────────┘
      │          1:1
      │                       ┌───────────┐
      └───────────────────────│ budgets   │
                              │           │
                              │ id (PK)   │
                              │ user_id   │→ FK (UNIQUE)
                              │ daily_    │
                              │ budget    │
                              │ weekly_   │
                              │ budget    │
                              │ monthly_  │
                              │ budget    │
                              └───────────┘
```

---

## 4. API Endpoint Design

Base URL: `/api/v1`

### Authentication

| Method | Endpoint         | Auth | Description                      |
| ------ | ---------------- | ---- | -------------------------------- |
| POST   | `/auth/register` | No   | Create account → returns tokens  |
| POST   | `/auth/login`    | No   | Authenticate → returns tokens    |
| POST   | `/auth/refresh`  | No   | Refresh JWT token pair           |
| GET    | `/auth/me`       | Yes  | Get current user profile         |
| DELETE | `/auth/me`       | Yes  | Delete account + all data (GDPR) |

### Expenses

| Method | Endpoint         | Auth | Description                       |
| ------ | ---------------- | ---- | --------------------------------- |
| POST   | `/expenses/`     | Yes  | Add a new expense                 |
| GET    | `/expenses/`     | Yes  | List expenses (paginated, filter) |
| GET    | `/expenses/{id}` | Yes  | Get single expense                |
| PUT    | `/expenses/{id}` | Yes  | Update expense                    |
| DELETE | `/expenses/{id}` | Yes  | Delete expense                    |

**Query params for GET /expenses/**: `skip`, `limit`, `category`, `start_date`, `end_date`

### Budgets

| Method | Endpoint             | Auth | Description                    |
| ------ | -------------------- | ---- | ------------------------------ |
| GET    | `/budgets/`          | Yes  | Get current budget             |
| PUT    | `/budgets/`          | Yes  | Set budget (create/replace)    |
| PATCH  | `/budgets/`          | Yes  | Partial update budget          |
| GET    | `/budgets/remaining` | Yes  | Get remaining budget breakdown |

### Summary / Analytics

| Method | Endpoint          | Auth | Description                  |
| ------ | ----------------- | ---- | ---------------------------- |
| GET    | `/summary/weekly` | Yes  | Weekly summary with insights |

### Health

| Method | Endpoint  | Auth | Description    |
| ------ | --------- | ---- | -------------- |
| GET    | `/health` | No   | Service health |

---

## 5. Security Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                         │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  TRANSPORT LAYER                                           │
│  ├─ HTTPS only (TLS 1.2+)                                │
│  ├─ HSTS header (Strict-Transport-Security)               │
│  └─ Certificate pinning (mobile)                          │
│                                                            │
│  AUTHENTICATION                                            │
│  ├─ JWT access tokens (30 min expiry)                     │
│  ├─ JWT refresh tokens (7 day expiry)                     │
│  ├─ bcrypt password hashing (salt rounds=12)              │
│  └─ OAuth2 Bearer scheme                                  │
│                                                            │
│  AUTHORIZATION                                             │
│  ├─ User scope isolation (users only see own data)        │
│  ├─ Every query filters by user_id                        │
│  └─ CASCADE delete for user data removal                  │
│                                                            │
│  INPUT VALIDATION                                          │
│  ├─ Pydantic schemas (type + constraint validation)       │
│  ├─ Email validation (EmailStr)                           │
│  ├─ String length limits                                  │
│  └─ Numeric bounds (amount > 0, budget >= 0)              │
│                                                            │
│  API PROTECTION                                            │
│  ├─ Rate limiting (60 req/min per IP)                     │
│  ├─ CORS whitelist                                        │
│  ├─ Trusted host middleware (production)                  │
│  └─ Auto-docs disabled in production                      │
│                                                            │
│  RESPONSE HEADERS                                          │
│  ├─ X-Content-Type-Options: nosniff                       │
│  ├─ X-Frame-Options: DENY                                 │
│  ├─ X-XSS-Protection: 1; mode=block                      │
│  ├─ Referrer-Policy: strict-origin-when-cross-origin      │
│  └─ Permissions-Policy: camera=(), microphone=()          │
│                                                            │
│  DATA PROTECTION                                           │
│  ├─ Passwords never stored in plain text                  │
│  ├─ Secrets in environment variables only                 │
│  ├─ No banking credentials stored                         │
│  ├─ Tokens stored in Flutter Secure Storage               │
│  └─ SQL injection prevented (parameterized ORM queries)   │
│                                                            │
│  INFRASTRUCTURE                                            │
│  ├─ Docker non-root user                                  │
│  ├─ Multi-stage builds (minimal attack surface)           │
│  └─ .env never committed to VCS                           │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 6. Deployment Workflow

### Backend Deployment

```
┌──────────┐    ┌──────────┐    ┌──────────────┐    ┌────────────┐
│  Push to │───▶│  CI/CD   │───▶│ Build Docker │───▶│  Deploy to │
│  main    │    │  Pipeline │    │   Image      │    │  Cloud     │
└──────────┘    └──────────┘    └──────────────┘    └────────────┘
                                                          │
                     ┌────────────────────────────────────┘
                     ▼
              Cloud Options:
              • AWS ECS / Fargate
              • Google Cloud Run
              • Azure Container Apps
              • Railway / Render
              • DigitalOcean App Platform
```

### Frontend Deployment

```
┌──────────┐    ┌──────────┐    ┌──────────────────────────┐
│  Push to │───▶│  CI/CD   │───▶│ flutter build apk        │
│  main    │    │  Pipeline │    │ flutter build ios         │
└──────────┘    └──────────┘    │ flutter build web         │
                                └──────────┬───────────────┘
                                           │
                           ┌───────────────┼───────────────┐
                           ▼               ▼               ▼
                    Google Play       App Store        Web Host
                      Store           Connect       (Firebase/
                                                    Vercel/S3)
```

### CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/backend.yml  (suggested structure)
name: Backend CI/CD
on:
  push:
    branches: [main]
    paths: [backend/**]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.11" }
      - run: pip install -e ".[dev]"
      - run: ruff check .
      - run: pytest --cov

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t expense-api ./backend
      # Push to container registry + deploy
```

---

## 7. Legal & Privacy Compliance

| Requirement                | Implementation                                  |
| -------------------------- | ----------------------------------------------- |
| Privacy Policy             | Settings screen links to hosted policy document |
| Terms of Service           | Settings screen links to hosted ToS document    |
| Data encryption in transit | HTTPS only + HSTS                               |
| Account deletion           | DELETE /auth/me removes user + CASCADE all data |
| Minimal data collection    | Only email + expense data (no banking, no PII)  |
| GDPR user data control     | Users can export/delete all their data          |
| No banking credentials     | App only tracks amounts, never bank access      |

---

## 8. Tech Stack Summary

| Layer      | Technology              | Purpose                       |
| ---------- | ----------------------- | ----------------------------- |
| Frontend   | Flutter 3.x / Dart      | Cross-platform mobile + web   |
| State      | Provider                | Lightweight state management  |
| Routing    | go_router               | Declarative navigation        |
| Charts     | fl_chart                | Pie & bar chart visualization |
| Storage    | flutter_secure_storage  | Encrypted token storage       |
| Backend    | FastAPI (Python 3.11)   | Async REST API                |
| ORM        | SQLAlchemy 2.x (async)  | Database abstraction          |
| Migrations | Alembic                 | Schema versioning             |
| Auth       | python-jose + passlib   | JWT + bcrypt                  |
| Validation | Pydantic v2             | Request/response schemas      |
| Rate Limit | slowapi                 | Per-IP request throttling     |
| Database   | PostgreSQL 16           | Primary data store            |
| Container  | Docker + docker-compose | Deployment packaging          |
