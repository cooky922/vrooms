import csv
from pathlib import Path
from typing import Optional, Union, Iterator, List

from src.database import SQLDatabase, Sorted, Paged, Search
from .entity_kind import EntityKind
from .errors import DatabaseError
from .fields import (
    CustomerField, UnitField, RentField, PaymentField, LiabilityField
)
from .validators import (
    validate_customer_field, validate_unit_field, validate_rent_field,
    validate_payment_field, validate_liability_field
)

def _build_where(search: Optional[Search], columns: list[str]) -> tuple[str, list]:
    if not search or not search.text:
        return '', []
    params = []
    if search.field:
        if search.prefix_match:
            clause = f'WHERE LOWER({search.field}) LIKE ?'
            params.append(search.text + '%')
        else:
            clause = f'WHERE LOWER({search.field}) LIKE ?'
            params.append('%' + search.text + '%')
    else:
        parts = [f'LOWER({col}) LIKE ?' for col in columns]
        clause = 'WHERE ' + ' OR '.join(parts)
        params = ['%' + search.text + '%'] * len(columns)
    return clause, params

def _build_order(sorted_: Optional[Sorted]) -> str:
    if not sorted_:
        return ''
    direction = 'ASC' if sorted_.ascending else 'DESC'
    return f'ORDER BY {sorted_.column} {direction}'

def _build_limit_offset(paged: Optional[Paged]) -> tuple[str, list]:
    if not paged:
        return '', []
    if paged.index is not None:
        offset = (paged.index - 1) * paged.size
        return 'LIMIT ? OFFSET ?', [paged.size, offset]
    return 'LIMIT ?', [paged.size]

class BaseRepository:
    TABLE: str = ''
    PK: str = ''
    COLUMNS: list[str] = []
    PARENT_FK: Optional[str] = None
    FIELD_ENUM = None

    @classmethod
    def get_primary_key(cls) -> str:
        return cls.PK

    @classmethod
    def get_columns(cls) -> list[str]:
        return cls.COLUMNS

    @classmethod
    def get_fields(cls) -> dict:
        return {f.value.internal_name: f.value for f in cls.FIELD_ENUM}

    @classmethod
    def get_keys(cls) -> list[str]:
        rows = SQLDatabase.fetch_all(f'SELECT {cls.PK} FROM {cls.TABLE}')
        return [r[cls.PK] for r in rows]

    @classmethod
    def _build_base_clause(cls, parent_id: Optional[str], search: Optional[Search]) -> tuple[str, list]:
        parts = []
        params = []
        
        if cls.PARENT_FK and parent_id:
            parts.append(f'{cls.PARENT_FK} = ?')
            params.append(parent_id)
            
        where, wp = _build_where(search, cls.COLUMNS)
        if wp:
            parts.append(where.replace('WHERE ', ''))
            params += wp
            
        clause = ('WHERE ' + ' AND '.join(parts)) if parts else ''
        return clause, params

    @classmethod
    def get_count(cls, search: Optional[Search] = None, parent_id: Optional[str] = None) -> int:
        clause, params = cls._build_base_clause(parent_id, search)
        return SQLDatabase.fetch_scalar(f'SELECT COUNT(*) FROM {cls.TABLE} {clause}', tuple(params)) or 0

    @classmethod
    def get_records(cls, search=None, sorted=None, paged=None, parent_id: Optional[str] = None) -> list[dict]:
        clause, params = cls._build_base_clause(parent_id, search)
        order = _build_order(sorted)
        limit, lp = _build_limit_offset(paged)
        return SQLDatabase.fetch_all(f'SELECT * FROM {cls.TABLE} {clause} {order} {limit}', tuple(params + lp))

    @classmethod
    def get_record(cls, key: str, parent_id: Optional[str] = None) -> Optional[dict]:
        if cls.PARENT_FK and parent_id:
            return SQLDatabase.fetch_one(f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?', (key, parent_id))
        return SQLDatabase.fetch_one(f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def check_duplicate_key(cls, key: str, parent_id: Optional[str] = None):
        if cls.get_record(key, parent_id):
            if cls.PARENT_FK:
                raise DatabaseError(f'ID "{key}" already exists for this parent record.')
            raise DatabaseError(f'ID "{key}" already exists.')

    @classmethod
    def add_record(cls, data: dict):
        cols = ', '.join(cls.COLUMNS)
        marks = ', '.join(['?'] * len(cls.COLUMNS))
        SQLDatabase.execute(f'INSERT INTO {cls.TABLE} ({cols}) VALUES ({marks})',
                            tuple(data.get(c) for c in cls.COLUMNS))

    @classmethod
    def update_record(cls, updates: dict, key: str, parent_id: Optional[str] = None):
        fields = [c for c in cls.COLUMNS if c not in (cls.PK, cls.PARENT_FK)]
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals = tuple(updates.get(c) for c in fields)
        
        if cls.PARENT_FK and parent_id:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?', vals + (key, parent_id))
        else:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals + (key,))

    @classmethod
    def delete_record(cls, key: str, parent_id: Optional[str] = None):
        if cls.PARENT_FK and parent_id:
            SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?', (key, parent_id))
        else:
            SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def delete_records(cls, keys: list[str]):
        if not keys: return
        marks = ', '.join(['?'] * len(keys))
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} IN ({marks})', tuple(keys))

class UnitRepository(BaseRepository):
    TABLE   = 'units'
    PK      = 'plateNumber'
    COLUMNS = [f.value.internal_name for f in UnitField]
    FIELD_ENUM = UnitField

    @classmethod
    def validate_field(cls, field: UnitField, value, _=None):
        validate_unit_field(field, value)

    @classmethod
    def update_records(cls, keys: list[str], updates: dict):
        fields = [c for c in updates if c != cls.PK]
        if not fields: return
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals = tuple(updates[c] for c in fields)
        for key in keys:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals + (key,))

class CustomerRepository(BaseRepository):
    TABLE   = 'customers'
    PK      = 'customerID'
    COLUMNS = [f.value.internal_name for f in CustomerField]
    FIELD_ENUM = CustomerField

    @classmethod
    def validate_field(cls, field: CustomerField, value, _=None):
        validate_customer_field(field, value)

    @classmethod
    def update_records(cls, keys: list[str], updates: dict):
        fields = [c for c in updates if c != cls.PK]
        if not fields: return
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals = tuple(updates[c] for c in fields)
        for key in keys:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals + (key,))

class RentRepository(BaseRepository):
    TABLE   = 'rents'
    PK      = 'rentalID'
    COLUMNS = [f.value.internal_name for f in RentField]
    FIELD_ENUM = RentField

    @classmethod
    def validate_field(cls, field: RentField, value, _=None):
        validate_rent_field(field, value)

    @classmethod
    def update_records(cls, keys: list[str], updates: dict):
        fields = [c for c in updates if c != cls.PK]
        if not fields: return
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals = tuple(updates[c] for c in fields)
        for key in keys:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals + (key,))

class PaymentRepository(BaseRepository):
    TABLE      = 'payments'
    PK         = 'paymentID'
    PARENT_FK  = 'rentalID'
    COLUMNS    = [f.value.internal_name for f in PaymentField]
    FIELD_ENUM = PaymentField

    @classmethod
    def validate_field(cls, field: PaymentField, value, _=None):
        validate_payment_field(field, value)

    @classmethod
    def delete_by_rental(cls, rental_id: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PARENT_FK} = ?', (rental_id,))

class LiabilityRepository(BaseRepository):
    TABLE      = 'liabilities'
    PK         = 'liabilityID'
    PARENT_FK  = 'rentalID'
    COLUMNS    = [f.value.internal_name for f in LiabilityField]
    FIELD_ENUM = LiabilityField

    @classmethod
    def validate_field(cls, field: LiabilityField, value, _=None):
        validate_liability_field(field, value)

    @classmethod
    def delete_by_rental(cls, rental_id: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PARENT_FK} = ?', (rental_id,))

REPOSITORY_MAP = {
    EntityKind.UNIT: UnitRepository,
    EntityKind.CUSTOMER: CustomerRepository,
    EntityKind.RENT: RentRepository,
    EntityKind.PAYMENT: PaymentRepository,
    EntityKind.LIABILITY: LiabilityRepository
}