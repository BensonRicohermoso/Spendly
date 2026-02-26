"""
V1 API router — aggregates all endpoint routers.
"""

from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.budgets import router as budget_router
from app.api.v1.expenses import router as expense_router
from app.api.v1.summary import router as summary_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(expense_router)
api_router.include_router(budget_router)
api_router.include_router(summary_router)
