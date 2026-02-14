"""
Application configuration loaded from environment variables.
All secrets are read from .env — never hardcoded.
"""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # ── App ──────────────────────────────────────────────
    app_name: str = "ExpenseBudgetTracker"
    app_env: str = "development"
    debug: bool = False
    api_v1_prefix: str = "/api/v1"

    # ── Server ───────────────────────────────────────────
    host: str = "0.0.0.0"
    port: int = 8000

    # ── Database ─────────────────────────────────────────
    database_url: str = "sqlite+aiosqlite:///./expense_tracker.db"

    # ── JWT ───────────────────────────────────────────────
    secret_key: str = "CHANGE_ME_TO_A_RANDOM_64_CHAR_STRING"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    # ── CORS ─────────────────────────────────────────────
    allowed_origins: str = "http://localhost:3000,http://localhost:8080"

    # ── Rate Limiting ────────────────────────────────────
    rate_limit_per_minute: int = 60

    # ── Logging ──────────────────────────────────────────
    log_level: str = "INFO"

    @property
    def cors_origins(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
