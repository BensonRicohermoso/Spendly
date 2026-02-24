"""
Pydantic schemas for budget operations.
"""

from pydantic import BaseModel, Field


class BudgetCreate(BaseModel):
    daily_budget: float = Field(ge=0, default=0)
    weekly_budget: float = Field(ge=0, default=0)
    monthly_budget: float = Field(ge=0, default=0)


class BudgetUpdate(BaseModel):
    daily_budget: float | None = Field(default=None, ge=0)
    weekly_budget: float | None = Field(default=None, ge=0)
    monthly_budget: float | None = Field(default=None, ge=0)


class BudgetOut(BaseModel):
    id: str
    user_id: str
    daily_budget: float
    weekly_budget: float
    monthly_budget: float

    model_config = {"from_attributes": True}


class BudgetRemainingOut(BaseModel):
    daily_budget: float
    weekly_budget: float
    monthly_budget: float
    spent_today: float
    spent_this_week: float
    spent_this_month: float
    remaining_daily: float
    remaining_weekly: float
    remaining_monthly: float
