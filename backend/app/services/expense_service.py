"""
Expense CRUD service.
"""

from datetime import datetime

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.expense import Expense
from app.schemas.expense import ExpenseCreate, ExpenseUpdate


async def create_expense(db: AsyncSession, user_id: str, data: ExpenseCreate) -> Expense:
    expense = Expense(
        user_id=user_id,
        amount=data.amount,
        category=data.category.strip(),
        note=data.note,
        date_created=data.date_created or datetime.utcnow(),
    )
    db.add(expense)
    await db.flush()
    return expense


async def get_expenses(
    db: AsyncSession,
    user_id: str,
    skip: int = 0,
    limit: int = 50,
    category: str | None = None,
    start_date: datetime | None = None,
    end_date: datetime | None = None,
) -> tuple[list[Expense], int]:
    query = select(Expense).where(Expense.user_id == user_id)
    count_query = select(func.count()).select_from(Expense).where(Expense.user_id == user_id)

    if category:
        query = query.where(Expense.category == category)
        count_query = count_query.where(Expense.category == category)
    if start_date:
        query = query.where(Expense.date_created >= start_date)
        count_query = count_query.where(Expense.date_created >= start_date)
    if end_date:
        query = query.where(Expense.date_created <= end_date)
        count_query = count_query.where(Expense.date_created <= end_date)

    query = query.order_by(Expense.date_created.desc()).offset(skip).limit(limit)

    result = await db.execute(query)
    total = await db.execute(count_query)
    return list(result.scalars().all()), total.scalar_one()


async def get_expense_by_id(db: AsyncSession, expense_id: str, user_id: str) -> Expense | None:
    result = await db.execute(
        select(Expense).where(Expense.id == expense_id, Expense.user_id == user_id)
    )
    return result.scalar_one_or_none()


async def update_expense(
    db: AsyncSession, expense_id: str, user_id: str, data: ExpenseUpdate
) -> Expense | None:
    values = {k: v for k, v in data.model_dump(exclude_unset=True).items() if v is not None}
    if not values:
        return await get_expense_by_id(db, expense_id, user_id)

    await db.execute(
        update(Expense)
        .where(Expense.id == expense_id, Expense.user_id == user_id)
        .values(**values)
    )
    await db.flush()
    return await get_expense_by_id(db, expense_id, user_id)


async def delete_expense(db: AsyncSession, expense_id: str, user_id: str) -> bool:
    result = await db.execute(
        delete(Expense).where(Expense.id == expense_id, Expense.user_id == user_id)
    )
    return result.rowcount > 0
