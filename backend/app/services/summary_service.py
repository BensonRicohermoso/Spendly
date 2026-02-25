"""
Weekly summary / analytics service.
"""

from datetime import datetime, timedelta, timezone

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.expense import Expense
from app.services.budget_service import get_or_create_budget


async def get_weekly_summary(db: AsyncSession, user_id: str) -> dict:
    now = datetime.now(timezone.utc)
    start_of_week = (now - timedelta(days=now.weekday())).replace(
        hour=0, minute=0, second=0, microsecond=0
    )
    start_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    # Total spending this week
    total_result = await db.execute(
        select(func.coalesce(func.sum(Expense.amount), 0)).where(
            Expense.user_id == user_id,
            Expense.date_created >= start_of_week,
            Expense.date_created <= now,
        )
    )
    total_spending = float(total_result.scalar_one())

    # Monthly spending (for remaining budget)
    monthly_result = await db.execute(
        select(func.coalesce(func.sum(Expense.amount), 0)).where(
            Expense.user_id == user_id,
            Expense.date_created >= start_of_month,
            Expense.date_created <= now,
        )
    )
    monthly_spending = float(monthly_result.scalar_one())

    budget = await get_or_create_budget(db, user_id)

    # Category breakdown
    cat_result = await db.execute(
        select(Expense.category, func.sum(Expense.amount).label("total"))
        .where(
            Expense.user_id == user_id,
            Expense.date_created >= start_of_week,
            Expense.date_created <= now,
        )
        .group_by(Expense.category)
        .order_by(func.sum(Expense.amount).desc())
    )
    categories = cat_result.all()
    category_breakdown = []
    for cat, total in categories:
        pct = (float(total) / total_spending * 100) if total_spending > 0 else 0
        category_breakdown.append({"category": cat, "total": float(total), "percentage": round(pct, 1)})

    # Daily spending for this week
    daily_result = await db.execute(
        select(
            func.date(Expense.date_created).label("day"),
            func.sum(Expense.amount).label("total"),
        )
        .where(
            Expense.user_id == user_id,
            Expense.date_created >= start_of_week,
            Expense.date_created <= now,
        )
        .group_by(func.date(Expense.date_created))
        .order_by(func.date(Expense.date_created))
    )
    daily_spending = [{"date": str(row.day), "total": float(row.total)} for row in daily_result.all()]

    # Simple insight
    remaining_weekly = float(budget.weekly_budget) - total_spending
    remaining_monthly = float(budget.monthly_budget) - monthly_spending

    if remaining_weekly < 0:
        insight = "You've exceeded your weekly budget. Consider reducing discretionary spending."
    elif remaining_weekly < float(budget.weekly_budget) * 0.2:
        insight = "You're nearing your weekly budget limit. Spend carefully for the rest of the week."
    else:
        insight = "You're on track with your weekly budget. Keep it up!"

    return {
        "total_spending": total_spending,
        "remaining_weekly_budget": remaining_weekly,
        "remaining_monthly_budget": remaining_monthly,
        "category_breakdown": category_breakdown,
        "daily_spending": daily_spending,
        "insight": insight,
    }
