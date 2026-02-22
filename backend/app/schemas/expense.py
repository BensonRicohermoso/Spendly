"""
Pydantic schemas for expense operations.
"""

from datetime import datetime

from pydantic import BaseModel, Field


class ExpenseCreate(BaseModel):
    amount: float = Field(gt=0, description="Expense amount (positive)")
    category: str = Field(min_length=1, max_length=100)
    note: str | None = Field(default=None, max_length=500)
    date_created: datetime | None = None


class ExpenseUpdate(BaseModel):
    amount: float | None = Field(default=None, gt=0)
    category: str | None = Field(default=None, min_length=1, max_length=100)
    note: str | None = Field(default=None, max_length=500)
    date_created: datetime | None = None


class ExpenseOut(BaseModel):
    id: str
    user_id: str
    amount: float
    category: str
    note: str | None
    date_created: datetime

    model_config = {"from_attributes": True}


class ExpenseListOut(BaseModel):
    items: list[ExpenseOut]
    total: int
