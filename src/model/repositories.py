from typing import Optional
from src.database import SQLDatabase, Sorted, Paged, Search
from .errors import DatabaseError, ValidationError
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


class CustomerRepository:
    TABLE   = 'customers'
    PK      = 'customer_id'
    COLUMNS = [f.value.internal_name for f in CustomerField]
    FIELD_ENUM = CustomerField

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
    def get_count(cls, search: Optional[Search] = None) -> int:
        where, params = _build_where(search, cls.COLUMNS)
        q = f'SELECT COUNT(*) FROM {cls.TABLE} {where}'
        return SQLDatabase.fetch_scalar(q, tuple(params)) or 0

    @classmethod
    def get_records(
        cls,
        search: Optional[Search] = None,
        sorted: Optional[Sorted] = None,
        paged: Optional[Paged] = None
    ) -> list[dict]:
        where, wp = _build_where(search, cls.COLUMNS)
        order      = _build_order(sorted)
        limit, lp  = _build_limit_offset(paged)
        q = f'SELECT * FROM {cls.TABLE} {where} {order} {limit}'
        return SQLDatabase.fetch_all(q, tuple(wp + lp))

    @classmethod
    def get_record(cls, key: str) -> Optional[dict]:
        return SQLDatabase.fetch_one(
            f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,)
        )

    @classmethod
    def check_duplicate_key(cls, key: str):
        row = SQLDatabase.fetch_one(
            f'SELECT {cls.PK} FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,)
        )
        if row:
            raise DatabaseError(f'Customer ID "{key}" already exists.')

    @classmethod
    def validate_field(cls, field: CustomerField, value, _=None):
        validate_customer_field(field, value)

    @classmethod
    def add_record(cls, data: dict):
        cols   = ', '.join(cls.COLUMNS)
        marks  = ', '.join(['?'] * len(cls.COLUMNS))
        vals   = tuple(data.get(c) for c in cls.COLUMNS)
        SQLDatabase.execute(f'INSERT INTO {cls.TABLE} ({cols}) VALUES ({marks})', vals)

    @classmethod
    def update_record(cls, updates: dict, key: str):
        set_clause = ', '.join(f'{c} = ?' for c in cls.COLUMNS if c != cls.PK)
        vals       = tuple(updates.get(c) for c in cls.COLUMNS if c != cls.PK) + (key,)
        SQLDatabase.execute(
            f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals
        )

    @classmethod
    def update_records(cls, keys: list[str], updates: dict):
        fields = [c for c in updates if c != cls.PK]
        if not fields:
            return
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals       = tuple(updates[c] for c in fields)
        for key in keys:
            SQLDatabase.execute(
                f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?',
                vals + (key,)
            )

    @classmethod
    def delete_record(cls, key: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def delete_records(cls, keys: list[str]):
        marks = ', '.join(['?'] * len(keys))
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} IN ({marks})', tuple(keys))


class UnitRepository:
    TABLE   = 'units'
    PK      = 'plate_number'
    COLUMNS = [f.value.internal_name for f in UnitField]
    FIELD_ENUM = UnitField

    @classmethod
    def get_primary_key(cls) -> str: return cls.PK

    @classmethod
    def get_columns(cls) -> list[str]: return cls.COLUMNS

    @classmethod
    def get_fields(cls) -> dict:
        return {f.value.internal_name: f.value for f in cls.FIELD_ENUM}

    @classmethod
    def get_keys(cls) -> list[str]:
        rows = SQLDatabase.fetch_all(f'SELECT {cls.PK} FROM {cls.TABLE}')
        return [r[cls.PK] for r in rows]

    @classmethod
    def get_count(cls, search: Optional[Search] = None) -> int:
        where, params = _build_where(search, cls.COLUMNS)
        return SQLDatabase.fetch_scalar(f'SELECT COUNT(*) FROM {cls.TABLE} {where}', tuple(params)) or 0

    @classmethod
    def get_records(cls, search=None, sorted=None, paged=None) -> list[dict]:
        where, wp = _build_where(search, cls.COLUMNS)
        order      = _build_order(sorted)
        limit, lp  = _build_limit_offset(paged)
        return SQLDatabase.fetch_all(f'SELECT * FROM {cls.TABLE} {where} {order} {limit}', tuple(wp + lp))

    @classmethod
    def get_record(cls, key: str) -> Optional[dict]:
        return SQLDatabase.fetch_one(f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def check_duplicate_key(cls, key: str):
        if SQLDatabase.fetch_one(f'SELECT {cls.PK} FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,)):
            raise DatabaseError(f'Plate Number "{key}" already exists.')

    @classmethod
    def validate_field(cls, field: UnitField, value, _=None):
        validate_unit_field(field, value)

    @classmethod
    def add_record(cls, data: dict):
        cols  = ', '.join(cls.COLUMNS)
        marks = ', '.join(['?'] * len(cls.COLUMNS))
        SQLDatabase.execute(f'INSERT INTO {cls.TABLE} ({cols}) VALUES ({marks})',
                            tuple(data.get(c) for c in cls.COLUMNS))

    @classmethod
    def update_record(cls, updates: dict, key: str):
        set_clause = ', '.join(f'{c} = ?' for c in cls.COLUMNS if c != cls.PK)
        vals       = tuple(updates.get(c) for c in cls.COLUMNS if c != cls.PK) + (key,)
        SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals)

    @classmethod
    def update_records(cls, keys: list[str], updates: dict):
        fields = [c for c in updates if c != cls.PK]
        if not fields:
            return
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals       = tuple(updates[c] for c in fields)
        for key in keys:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals + (key,))

    @classmethod
    def delete_record(cls, key: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def delete_records(cls, keys: list[str]):
        marks = ', '.join(['?'] * len(keys))
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} IN ({marks})', tuple(keys))


class RentRepository:
    TABLE   = 'rents'
    PK      = 'rental_id'
    COLUMNS = [f.value.internal_name for f in RentField]
    FIELD_ENUM = RentField

    @classmethod
    def get_primary_key(cls) -> str: return cls.PK

    @classmethod
    def get_columns(cls) -> list[str]: return cls.COLUMNS

    @classmethod
    def get_fields(cls) -> dict:
        return {f.value.internal_name: f.value for f in cls.FIELD_ENUM}

    @classmethod
    def get_keys(cls) -> list[str]:
        rows = SQLDatabase.fetch_all(f'SELECT {cls.PK} FROM {cls.TABLE}')
        return [r[cls.PK] for r in rows]

    @classmethod
    def get_count(cls, search: Optional[Search] = None) -> int:
        where, params = _build_where(search, cls.COLUMNS)
        return SQLDatabase.fetch_scalar(f'SELECT COUNT(*) FROM {cls.TABLE} {where}', tuple(params)) or 0

    @classmethod
    def get_records(cls, search=None, sorted=None, paged=None) -> list[dict]:
        where, wp = _build_where(search, cls.COLUMNS)
        order      = _build_order(sorted)
        limit, lp  = _build_limit_offset(paged)
        return SQLDatabase.fetch_all(f'SELECT * FROM {cls.TABLE} {where} {order} {limit}', tuple(wp + lp))

    @classmethod
    def get_record(cls, key: str) -> Optional[dict]:
        return SQLDatabase.fetch_one(f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def check_duplicate_key(cls, key: str):
        if SQLDatabase.fetch_one(f'SELECT {cls.PK} FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,)):
            raise DatabaseError(f'Rental ID "{key}" already exists.')

    @classmethod
    def validate_field(cls, field: RentField, value, _=None):
        validate_rent_field(field, value)

    @classmethod
    def add_record(cls, data: dict):
        cols  = ', '.join(cls.COLUMNS)
        marks = ', '.join(['?'] * len(cls.COLUMNS))
        SQLDatabase.execute(f'INSERT INTO {cls.TABLE} ({cols}) VALUES ({marks})',
                            tuple(data.get(c) for c in cls.COLUMNS))

    @classmethod
    def update_record(cls, updates: dict, key: str):
        set_clause = ', '.join(f'{c} = ?' for c in cls.COLUMNS if c != cls.PK)
        vals       = tuple(updates.get(c) for c in cls.COLUMNS if c != cls.PK) + (key,)
        SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals)

    @classmethod
    def update_records(cls, keys: list[str], updates: dict):
        fields = [c for c in updates if c != cls.PK]
        if not fields:
            return
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals       = tuple(updates[c] for c in fields)
        for key in keys:
            SQLDatabase.execute(f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ?', vals + (key,))

    @classmethod
    def delete_record(cls, key: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ?', (key,))

    @classmethod
    def delete_records(cls, keys: list[str]):
        marks = ', '.join(['?'] * len(keys))
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PK} IN ({marks})', tuple(keys))


class PaymentRepository:
    TABLE      = 'payments'
    PK         = 'payment_id'
    PARENT_FK  = 'rental_id'
    COLUMNS    = [f.value.internal_name for f in PaymentField]
    FIELD_ENUM = PaymentField

    @classmethod
    def get_primary_key(cls) -> str: return cls.PK

    @classmethod
    def get_columns(cls) -> list[str]: return cls.COLUMNS

    @classmethod
    def get_fields(cls) -> dict:
        return {f.value.internal_name: f.value for f in cls.FIELD_ENUM}

    @classmethod
    def get_count(cls, rental_id: Optional[str] = None, search: Optional[Search] = None) -> int:
        base  = f'SELECT COUNT(*) FROM {cls.TABLE}'
        parts = []
        params = []
        if rental_id:
            parts.append(f'{cls.PARENT_FK} = ?')
            params.append(rental_id)
        where, wp = _build_where(search, cls.COLUMNS)
        if wp:
            parts.append(where.replace('WHERE ', ''))
            params += wp
        clause = ('WHERE ' + ' AND '.join(parts)) if parts else ''
        return SQLDatabase.fetch_scalar(f'{base} {clause}', tuple(params)) or 0

    @classmethod
    def get_records(cls, rental_id: Optional[str] = None, search=None, sorted=None, paged=None) -> list[dict]:
        parts  = []
        params = []
        if rental_id:
            parts.append(f'{cls.PARENT_FK} = ?')
            params.append(rental_id)
        where, wp = _build_where(search, cls.COLUMNS)
        if wp:
            parts.append(where.replace('WHERE ', ''))
            params += wp
        clause = ('WHERE ' + ' AND '.join(parts)) if parts else ''
        order  = _build_order(sorted)
        limit, lp = _build_limit_offset(paged)
        return SQLDatabase.fetch_all(
            f'SELECT * FROM {cls.TABLE} {clause} {order} {limit}', tuple(params + lp)
        )

    @classmethod
    def get_record(cls, payment_id: str, rental_id: str) -> Optional[dict]:
        return SQLDatabase.fetch_one(
            f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?',
            (payment_id, rental_id)
        )

    @classmethod
    def check_duplicate_key(cls, payment_id: str, rental_id: str):
        if cls.get_record(payment_id, rental_id):
            raise DatabaseError(f'Payment ID "{payment_id}" already exists for this rental.')

    @classmethod
    def validate_field(cls, field: PaymentField, value, _=None):
        validate_payment_field(field, value)

    @classmethod
    def add_record(cls, data: dict):
        cols  = ', '.join(cls.COLUMNS)
        marks = ', '.join(['?'] * len(cls.COLUMNS))
        SQLDatabase.execute(f'INSERT INTO {cls.TABLE} ({cols}) VALUES ({marks})',
                            tuple(data.get(c) for c in cls.COLUMNS))

    @classmethod
    def update_record(cls, updates: dict, payment_id: str, rental_id: str):
        fields     = [c for c in cls.COLUMNS if c not in (cls.PK, cls.PARENT_FK)]
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals       = tuple(updates.get(c) for c in fields) + (payment_id, rental_id)
        SQLDatabase.execute(
            f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?', vals
        )

    @classmethod
    def delete_record(cls, payment_id: str, rental_id: str):
        SQLDatabase.execute(
            f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?',
            (payment_id, rental_id)
        )

    @classmethod
    def delete_by_rental(cls, rental_id: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PARENT_FK} = ?', (rental_id,))


class LiabilityRepository:
    TABLE      = 'liabilities'
    PK         = 'liability_id'
    PARENT_FK  = 'rental_id'
    COLUMNS    = [f.value.internal_name for f in LiabilityField]
    FIELD_ENUM = LiabilityField

    @classmethod
    def get_primary_key(cls) -> str: return cls.PK

    @classmethod
    def get_columns(cls) -> list[str]: return cls.COLUMNS

    @classmethod
    def get_fields(cls) -> dict:
        return {f.value.internal_name: f.value for f in cls.FIELD_ENUM}

    @classmethod
    def get_count(cls, rental_id: Optional[str] = None, search: Optional[Search] = None) -> int:
        parts  = []
        params = []
        if rental_id:
            parts.append(f'{cls.PARENT_FK} = ?')
            params.append(rental_id)
        where, wp = _build_where(search, cls.COLUMNS)
        if wp:
            parts.append(where.replace('WHERE ', ''))
            params += wp
        clause = ('WHERE ' + ' AND '.join(parts)) if parts else ''
        return SQLDatabase.fetch_scalar(f'SELECT COUNT(*) FROM {cls.TABLE} {clause}', tuple(params)) or 0

    @classmethod
    def get_records(cls, rental_id: Optional[str] = None, search=None, sorted=None, paged=None) -> list[dict]:
        parts  = []
        params = []
        if rental_id:
            parts.append(f'{cls.PARENT_FK} = ?')
            params.append(rental_id)
        where, wp = _build_where(search, cls.COLUMNS)
        if wp:
            parts.append(where.replace('WHERE ', ''))
            params += wp
        clause = ('WHERE ' + ' AND '.join(parts)) if parts else ''
        order  = _build_order(sorted)
        limit, lp = _build_limit_offset(paged)
        return SQLDatabase.fetch_all(
            f'SELECT * FROM {cls.TABLE} {clause} {order} {limit}', tuple(params + lp)
        )

    @classmethod
    def get_record(cls, liability_id: str, rental_id: str) -> Optional[dict]:
        return SQLDatabase.fetch_one(
            f'SELECT * FROM {cls.TABLE} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?',
            (liability_id, rental_id)
        )

    @classmethod
    def check_duplicate_key(cls, liability_id: str, rental_id: str):
        if cls.get_record(liability_id, rental_id):
            raise DatabaseError(f'Liability ID "{liability_id}" already exists for this rental.')

    @classmethod
    def validate_field(cls, field: LiabilityField, value, _=None):
        validate_liability_field(field, value)

    @classmethod
    def add_record(cls, data: dict):
        cols  = ', '.join(cls.COLUMNS)
        marks = ', '.join(['?'] * len(cls.COLUMNS))
        SQLDatabase.execute(f'INSERT INTO {cls.TABLE} ({cols}) VALUES ({marks})',
                            tuple(data.get(c) for c in cls.COLUMNS))

    @classmethod
    def update_record(cls, updates: dict, liability_id: str, rental_id: str):
        fields     = [c for c in cls.COLUMNS if c not in (cls.PK, cls.PARENT_FK)]
        set_clause = ', '.join(f'{c} = ?' for c in fields)
        vals       = tuple(updates.get(c) for c in fields) + (liability_id, rental_id)
        SQLDatabase.execute(
            f'UPDATE {cls.TABLE} SET {set_clause} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?', vals
        )

    @classmethod
    def delete_record(cls, liability_id: str, rental_id: str):
        SQLDatabase.execute(
            f'DELETE FROM {cls.TABLE} WHERE {cls.PK} = ? AND {cls.PARENT_FK} = ?',
            (liability_id, rental_id)
        )

    @classmethod
    def delete_by_rental(cls, rental_id: str):
        SQLDatabase.execute(f'DELETE FROM {cls.TABLE} WHERE {cls.PARENT_FK} = ?', (rental_id,))