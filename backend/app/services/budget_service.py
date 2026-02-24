"""
Budget CRUD service + remaining-budget calculation.
"""

from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.budget import Budget
from app.models.expense import Expense
from app.schemas.budget import BudgetCreate, BudgetUpdate


async def get_or_create_budget(db: AsyncSession, user_id: str) -> Budget:
    result = await db.execute(select(Budget).where(Budget.user_id == user_id))
    budget = result.scalar_one_or_none()
    if budget is None:
        budget = Budget(user_id=user_id)
        db.add(budget)
        await db.flush()
    return budget


async def update_budget(db: AsyncSession, user_id: str, data: BudgetCreate | BudgetUpdate) -> Budget:
    budget = await get_or_create_budget(db, user_id)
    for field, value in data.model_dump(exclude_unset=True).items():
        if value is not None:
            setattr(budget, field, value)
    await db.flush()
    return budget


async def get_remaining_budget(db: AsyncSession, user_id: str) -> dict:
    budget = await get_or_create_budget(db, user_id)
    now = datetime.now(timezone.utc)

    # Start of today
    start_of_day = now.replace(hour=0, minute=0, second=0, microsecond=0)
    # Start of week (Monday)
    start_of_week = start_of_day - timedelta(days=now.weekday())
    # Start of month
    start_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    spent_today = await _sum_expenses(db, user_id, start_of_day, now)
    spent_this_week = await _sum_expenses(db, user_id, start_of_week, now)
    spent_this_month = await _sum_expenses(db, user_id, start_of_month, now)

    return {
        "daily_budget": float(budget.daily_budget),
        "weekly_budget": float(budget.weekly_budget),
        "monthly_budget": float(budget.monthly_budget),
        "spent_today": spent_today,
        "spent_this_week": spent_this_week,
        "spent_this_month": spent_this_month,
        "remaining_daily": float(budget.daily_budget) - spent_today,
        "remaining_weekly": float(budget.weekly_budget) - spent_this_week,
        "remaining_monthly": float(budget.monthly_budget) - spent_this_month,
    }


async def _sum_expenses(
    db: AsyncSession, user_id: str, start: datetime, end: datetime
) -> float:
    result = await db.execute(
        select(func.coalesce(func.sum(Expense.amount), 0)).where(
            Expense.user_id == user_id,
            Expense.date_created >= start,
            Expense.date_created <= end,
        )
    )
    return float(result.scalar_one())
