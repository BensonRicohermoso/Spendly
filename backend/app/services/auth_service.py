"""
Authentication service — registration, login, token refresh, password reset.
"""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.user import User


async def register_user(db: AsyncSession, email: str, password: str) -> User:
    """Create a new user with a hashed password."""
    user = User(email=email.lower().strip(), hashed_password=hash_password(password))
    db.add(user)
    await db.flush()
    return user


async def authenticate_user(db: AsyncSession, email: str, password: str) -> User | None:
    """Return user if credentials are valid, else None."""
    result = await db.execute(select(User).where(User.email == email.lower().strip()))
    user = result.scalar_one_or_none()
    if user is None or not verify_password(password, user.hashed_password):
        return None
    return user


async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    result = await db.execute(select(User).where(User.email == email.lower().strip()))
    return result.scalar_one_or_none()


def issue_tokens(user_id: str) -> dict:
    return {
        "access_token": create_access_token(subject=user_id),
        "refresh_token": create_refresh_token(subject=user_id),
        "token_type": "bearer",
    }


def refresh_access_token(refresh_token: str) -> dict | None:
    """Validate refresh token and issue a new access token."""
    payload = decode_token(refresh_token)
    if payload is None or payload.get("type") != "refresh":
        return None
    user_id = payload.get("sub")
    if user_id is None:
        return None
    return {
        "access_token": create_access_token(subject=user_id),
        "refresh_token": create_refresh_token(subject=user_id),
        "token_type": "bearer",
    }
