"""
Summary / Analytics API endpoints.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.schemas.summary import WeeklySummaryOut
from app.services.summary_service import get_weekly_summary

router = APIRouter(prefix="/summary", tags=["Summary"])


@router.get("/weekly", response_model=WeeklySummaryOut)
async def weekly_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_weekly_summary(db, current_user.id)
