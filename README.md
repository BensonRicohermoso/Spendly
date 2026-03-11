# Expense & Budget Tracker

A production-ready personal finance tracking application built with **FastAPI** (backend) and **Flutter** (frontend).

Track expenses, set budgets, visualize spending, and receive weekly insights — across Android, iOS, and web.

---

## Quick Start

### Prerequisites

| Tool       | Version | Install                              |
| ---------- | ------- | ------------------------------------ |
| Python     | ≥ 3.11  | https://python.org                   |
| PostgreSQL | ≥ 15    | https://postgresql.org               |
| Flutter    | ≥ 3.2   | https://docs.flutter.dev/get-started |
| Docker     | ≥ 24    | https://docs.docker.com/get-docker   |
| Git        | latest  | https://git-scm.com                  |

---

### Option A: Run with Docker (Recommended)

This starts PostgreSQL + the API in containers.

```bash
# 1. Clone the repo
git clone <your-repo-url> && cd startup

# 2. Create backend env file
cp backend/.env.example backend/.env
# Edit backend/.env — set a strong SECRET_KEY (64+ random chars)

# 3. Start everything
docker-compose up --build

# API is now running at http://localhost:8000
# Swagger docs at    http://localhost:8000/docs
```

---

### Option B: Run Backend Locally (without Docker)

```bash
# 1. Create and activate a virtual environment
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

# 2. Install dependencies
pip install -e ".[dev]"

# 3. Set up environment
cp .env.example .env
# Edit .env — set DATABASE_URL to your PostgreSQL connection string
# Set a strong SECRET_KEY

# 4. Create the database
# In psql or pgAdmin:
#   CREATE DATABASE expense_tracker;

# 5. Run database migrations
alembic revision --autogenerate -m "Initial tables"
alembic upgrade head

# 6. Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API is now at `http://localhost:8000` with interactive docs at `/docs`.

---

### Run Frontend (Flutter)

```bash
# 1. Navigate to frontend directory
cd frontend

# 2. Get dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# Or target a specific platform:
flutter run -d chrome      # Web
flutter run -d android     # Android emulator
flutter run -d ios         # iOS simulator (macOS only)
```

**API URL configuration**: Edit `lib/core/api_config.dart` to point to your backend:

- Android emulator → `http://10.0.2.2:8000/api/v1`
- iOS simulator / Web → `http://localhost:8000/api/v1`
- Production → `https://yourdomain.com/api/v1`

---

## Build for Production

### Backend

```bash
cd backend
docker build -t expense-tracker-api .
docker run -p 8000:8000 --env-file .env expense-tracker-api
```

### Frontend

```bash
cd frontend

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web --release
```

---

## Project Structure

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full architecture documentation including:

- System architecture diagram
- Complete folder structure
- Database schema & ER diagram
- API endpoint reference
- Security architecture
- Deployment workflows
- Tech stack summary

---

## API Quick Reference

All endpoints are prefixed with `/api/v1`.

| Endpoint             | Method | Auth | Purpose               |
| -------------------- | ------ | ---- | --------------------- |
| `/auth/register`     | POST   | No   | Create account        |
| `/auth/login`        | POST   | No   | Sign in → get tokens  |
| `/auth/refresh`      | POST   | No   | Refresh token pair    |
| `/auth/me`           | GET    | Yes  | Get profile           |
| `/auth/me`           | DELETE | Yes  | Delete account (GDPR) |
| `/expenses/`         | POST   | Yes  | Add expense           |
| `/expenses/`         | GET    | Yes  | List expenses         |
| `/expenses/{id}`     | GET    | Yes  | Get expense           |
| `/expenses/{id}`     | PUT    | Yes  | Update expense        |
| `/expenses/{id}`     | DELETE | Yes  | Delete expense        |
| `/budgets/`          | GET    | Yes  | Get budget            |
| `/budgets/`          | PUT    | Yes  | Set budget            |
| `/budgets/remaining` | GET    | Yes  | Remaining budget      |
| `/summary/weekly`    | GET    | Yes  | Weekly summary        |
| `/health`            | GET    | No   | Health check          |

---

## Security

- HTTPS-only with HSTS headers
- JWT authentication (access + refresh tokens)
- bcrypt password hashing
- Rate limiting (60 req/min per IP)
- Input validation via Pydantic
- SQL injection prevention (ORM parameterized queries)
- CORS whitelist
- Security response headers (X-Frame-Options, CSP, etc.)
- Secrets in environment variables only
- Docker runs as non-root user
- User data isolation (users only access their own data)

---

## License

Proprietary — All rights reserved.
