"""
Budget SQLAlchemy model.
"""

import uuid

from sqlalchemy import ForeignKey, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Budget(Base):
    __tablename__ = "budgets"

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
    )
    user_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
        index=True,
    )
    daily_budget: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    weekly_budget: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    monthly_budget: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False, default=0)

    # Relationships
    user = relationship("User", back_populates="budget")
