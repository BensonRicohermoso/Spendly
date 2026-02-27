"""
Basic tests verifying core imports and configuration.
"""

from app.core.config import get_settings
from app.core.security import create_access_token, decode_token, hash_password, verify_password


def test_settings_load():
    settings = get_settings()
    assert settings.app_name == "ExpenseBudgetTracker"
    assert settings.api_v1_prefix == "/api/v1"


def test_password_hashing():
    password = "TestPassword123!"
    hashed = hash_password(password)
    assert hashed != password
    assert verify_password(password, hashed)
    assert not verify_password("wrong", hashed)


def test_jwt_round_trip():
    user_id = "test-user-id"
    token = create_access_token(subject=user_id)
    payload = decode_token(token)
    assert payload is not None
    assert payload["sub"] == user_id
    assert payload["type"] == "access"


def test_invalid_token():
    assert decode_token("invalid.jwt.token") is None
