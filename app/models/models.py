from datetime import datetime
from typing import List

from sqlalchemy import Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db import db


class StoreModel(db.Model):
    __tablename__ = "stores"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(30), nullable=False)

    items: Mapped[List["ItemModel"]] = relationship(
        back_populates="store", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"Store(id={self.id}, name={self.name}"


class ItemModel(db.Model):
    __tablename__ = "items"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(20), nullable=False)
    price: Mapped[float] = mapped_column(Float(precision=2))
    store_id: Mapped[int] = mapped_column(ForeignKey("stores.id"))

    store: Mapped["StoreModel"] = relationship(back_populates="items")

    def __repr__(self) -> str:
        return f"Item(id={self.id}, name={self.name}, price={self.price})"


class UserModel(db.Model):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(20), nullable=False, unique=True)
    password: Mapped[str] = mapped_column(String(20), nullable=False, unique=False)


class Blocklist(db.Model):
    __tablename__ = "blocklist"

    id: Mapped[int] = mapped_column(primary_key=True)
    jti: Mapped[str] = mapped_column(nullable=False, unique=True)
    created_date: Mapped[datetime] = mapped_column(default=datetime.now())
