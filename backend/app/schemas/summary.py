"""
Pydantic schemas for summary / analytics.
"""

from pydantic import BaseModel


class CategoryBreakdown(BaseModel):
    category: str
    total: float
    percentage: float


class DailySpending(BaseModel):
    date: str
    total: float


class WeeklySummaryOut(BaseModel):
    total_spending: float
    remaining_weekly_budget: float
    remaining_monthly_budget: float
    category_breakdown: list[CategoryBreakdown]
    daily_spending: list[DailySpending]
    insight: str
