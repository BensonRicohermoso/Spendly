"""
Budget API endpoints.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.schemas.budget import BudgetCreate, BudgetOut, BudgetRemainingOut, BudgetUpdate
from app.services.budget_service import get_or_create_budget, get_remaining_budget, update_budget

router = APIRouter(prefix="/budgets", tags=["Budgets"])


@router.get("/", response_model=BudgetOut)
async def get_budget(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    budget = await get_or_create_budget(db, current_user.id)
    return budget


@router.put("/", response_model=BudgetOut)
async def set_budget(
    body: BudgetCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    budget = await update_budget(db, current_user.id, body)
    return budget


@router.patch("/", response_model=BudgetOut)
async def patch_budget(
    body: BudgetUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    budget = await update_budget(db, current_user.id, body)
    return budget


@router.get("/remaining", response_model=BudgetRemainingOut)
async def remaining_budget(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_remaining_budget(db, current_user.id)
