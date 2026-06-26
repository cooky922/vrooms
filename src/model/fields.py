from dataclasses import dataclass, asdict
from enum import Enum
from typing import Optional, List, Dict, Any

UNIT_STATUS_OPTIONS      = ['Available', 'Rented', 'Maintenance']
CUSTOMER_STATUS_OPTIONS  = ['Active', 'Blacklisted']
RENT_STATUS_OPTIONS      = ['Ongoing', 'Closed']
LIABILITY_STATUS_OPTIONS = ['Pending', 'Settled']

class FieldType(Enum):
    TEXT     = 'text'
    REAL     = 'real'
    INT      = 'int'
    DATE     = 'date'
    DATETIME = 'datetime'
    FILE     = 'file'
    SELECT   = 'select'

@dataclass(frozen=True)
class FieldInfo:
    internal_name:  str
    display_name:   str
    type:           FieldType
    required:       bool = True
    is_primary_key: bool = False
    is_foreign_key: bool = False
    placeholder:   Optional[str] = None
    options:       Optional[List[str]] = None
    max_length:    Optional[int] = None
    dynamic_source: Optional[str] = None  # Set to "availableUnits" or "activeCustomers" for live dropdown data

    def to_dict(self) -> Dict[str, Any]:
        data = {
            'key':            self.internal_name,
            'label':          self.display_name,
            'type':           self.type.value,
            'required':       self.required,
            'is_primary_key': self.is_primary_key,
            'is_foreign_key': self.is_foreign_key,
        }
        if self.placeholder is not None:
            data['placeholder'] = self.placeholder
        if self.options is not None:
            data['options'] = self.options
        if self.max_length is not None:
            data['max_length'] = self.max_length
        if self.dynamic_source is not None:
            data['dynamic_source'] = self.dynamic_source
        return data


class UnitField(Enum):
    UNIT_ID = FieldInfo(
        'unitID', 'ID',
        type=FieldType.INT,
        required=True,
        is_primary_key=True,
        placeholder='e.g. 1',
    )
    PLATE_NUMBER = FieldInfo(
        'plateNumber', 'Plate Number',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. ABC-1234',
        max_length=15,
    )
    UNIT_BRAND = FieldInfo(
        'unitBrand', 'Brand',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. Toyota',
        max_length=30,
    )
    UNIT_MODEL = FieldInfo(
        'unitModel', 'Model',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. Camry',
        max_length=50,
    )
    UNIT_COLOR = FieldInfo(
        'unitColor', 'Color',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. Red',
        max_length=30,
    )
    UNIT_YEAR = FieldInfo(
        'unitYear', 'Year',
        type=FieldType.INT,
        required=True,
        placeholder='e.g. 2024',
    )
    UNIT_PICTURE = FieldInfo(
        'unitPicture', 'Picture',
        type=FieldType.FILE,
        required=False,
        max_length=255,
    )
    UNIT_STATUS = FieldInfo(
        'unitStatus', 'Status',
        type=FieldType.SELECT,
        required=True,
        options=UNIT_STATUS_OPTIONS,
    )
    DAILY_RATE = FieldInfo(
        'dailyRate', 'Daily Rate (₱)',
        type=FieldType.REAL,
        required=True,
        placeholder='e.g. 300.0',
    )
    DATE_ADDED = FieldInfo(
        'dateAdded', 'Date Added',
        type=FieldType.DATE,
        required=True,
        placeholder='YYYY-MM-DD',
    )

    @staticmethod
    def from_internal_name(name: str) -> 'UnitField':
        for field in UnitField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')

    @staticmethod
    def get_fields() -> dict[str, FieldInfo]:
        return {field.value.internal_name: field.value for field in UnitField}


class CustomerField(Enum):
    CUSTOMER_ID = FieldInfo(
        'customerID', 'ID',
        type=FieldType.INT,
        required=True,
        is_primary_key=True,
        placeholder='e.g. 1',
    )
    FIRST_NAME = FieldInfo(
        'firstName', 'First Name',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. Juan',
        max_length=50,
    )
    LAST_NAME = FieldInfo(
        'lastName', 'Last Name',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. Dela Cruz',
        max_length=50,
    )
    PHONE_NUMBER = FieldInfo(
        'phoneNumber', 'Phone Number',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. 09123456789',
        max_length=11,
    )
    EMAIL_ADDRESS = FieldInfo(
        'emailAddress', 'Email Address',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. juan@example.com',
        max_length=100,
    )
    HOME_ADDRESS = FieldInfo(
        'homeAddress', 'Home Address',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. 123 Main St',
        max_length=255,
    )
    PROFILE_PICTURE = FieldInfo(
        'profilePicture', 'Profile Picture',
        type=FieldType.FILE,
        required=False,
        max_length=255,
    )
    DRIVER_LICENSE_ID = FieldInfo(
        'driverLicenseID', 'Driver License ID',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. DL-0001',
        max_length=15,
    )
    DRIVER_LICENSE_PICTURE = FieldInfo(
        'driverLicenseIDPicture', 'Driver License Picture',
        type=FieldType.FILE,
        required=True,
        max_length=255,
    )
    DRIVER_LICENSE_EXPIRY_DATE = FieldInfo(
        'driverLicenseExpiryDate', 'License Expiry Date',
        type=FieldType.DATE,
        required=True,
        placeholder='YYYY-MM-DD',
    )
    CUSTOMER_STATUS = FieldInfo(
        'customerStatus', 'Status',
        type=FieldType.SELECT,
        required=True,
        options=CUSTOMER_STATUS_OPTIONS,
    )
    DATE_REGISTERED = FieldInfo(
        'dateRegistered', 'Date Registered',
        type=FieldType.DATE,
        required=True,
        placeholder='YYYY-MM-DD',
    )

    @staticmethod
    def from_internal_name(name: str) -> 'CustomerField':
        for field in CustomerField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')

    @staticmethod
    def get_fields() -> dict[str, FieldInfo]:
        return {field.value.internal_name: field.value for field in CustomerField}


class RentField(Enum):
    RENT_ID = FieldInfo(
        'rentID', 'ID',
        type=FieldType.INT,
        required=True,
        is_primary_key=True,
        placeholder='e.g. 1',
    )
    CUSTOMER_ID = FieldInfo(
        'customerID', 'Customer ID',
        type=FieldType.INT,
        required=True,
        is_foreign_key=True,
        placeholder='e.g. 1',
        dynamic_source='activeCustomers'  # Dropdown shows only Active customers
    )
    UNIT_ID = FieldInfo(
        'unitID', 'Unit ID',
        type=FieldType.INT,
        required=True,
        is_foreign_key=True,
        placeholder='e.g. 1',
        dynamic_source='availableUnits'   # Dropdown shows only Available units
    )
    RENT_STATUS = FieldInfo(
        'rentStatus', 'Status',
        type=FieldType.SELECT,
        required=True,
        options=RENT_STATUS_OPTIONS,
    )
    RENT_DATETIME = FieldInfo(
        'rentDateTime', 'Rent Date & Time',
        type=FieldType.DATETIME,
        required=True,
        placeholder='YYYY-MM-DD HH:MM:SS',
    )
    EXPECTED_RETURN_DATETIME = FieldInfo(
        'expectedReturnDateTime', 'Expected Return Date & Time',
        type=FieldType.DATETIME,
        required=True,
        placeholder='YYYY-MM-DD HH:MM:SS',
    )
    ACTUAL_RETURN_DATETIME = FieldInfo(
        'actualReturnDateTime', 'Actual Return Date & Time',
        type=FieldType.DATETIME,
        required=False,
        placeholder='YYYY-MM-DD HH:MM:SS',
    )
    RENT_FEE = FieldInfo(
        'rentFee', 'Rent Fee (₱)',
        type=FieldType.REAL,
        required=True,
        placeholder='e.g. 1200.0',
    )

    @staticmethod
    def from_internal_name(name: str) -> 'RentField':
        for field in RentField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')

    @staticmethod
    def get_fields() -> dict[str, FieldInfo]:
        return {field.value.internal_name: field.value for field in RentField}


class LiabilityField(Enum):
    LIABILITY_ID = FieldInfo(
        'liabilityID', 'ID',
        type=FieldType.INT,
        required=True,
        is_primary_key=True,
        placeholder='e.g. 1',
    )
    CUSTOMER_ID = FieldInfo(
        'customerID', 'Customer ID',
        type=FieldType.INT,
        required=True,
        is_foreign_key=True,
        placeholder='e.g. 1',
        dynamic_source='activeCustomers'
    )
    LIABILITY_DESCRIPTION = FieldInfo(
        'liabilityDescription', 'Description',
        type=FieldType.TEXT,
        required=True,
        placeholder='e.g. Broken side mirror',
        max_length=255,
    )
    LIABILITY_FEE = FieldInfo(
        'liabilityFee', 'Liability Fee (₱)',
        type=FieldType.REAL,
        required=True,
        placeholder='e.g. 500.0',
    )
    LIABILITY_STATUS = FieldInfo(
        'liabilityStatus', 'Status',
        type=FieldType.SELECT,
        required=True,
        options=LIABILITY_STATUS_OPTIONS,
    )
    ISSUED_DATETIME = FieldInfo(
        'issuedDateTime', 'Issued Date & Time',
        type=FieldType.DATETIME,
        required=True,
        placeholder='YYYY-MM-DD HH:MM:SS',
    )

    @staticmethod
    def from_internal_name(name: str) -> 'LiabilityField':
        for field in LiabilityField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')

    @staticmethod
    def get_fields() -> dict[str, FieldInfo]:
        return {field.value.internal_name: field.value for field in LiabilityField}


class PaymentField(Enum):
    PAYMENT_ID = FieldInfo(
        'paymentID', 'ID',
        type=FieldType.INT,
        required=True,
        is_primary_key=True,
        placeholder='e.g. 1',
    )
    CUSTOMER_ID = FieldInfo(
        'customerID', 'Customer ID',
        type=FieldType.INT,
        required=True,
        is_foreign_key=True,
        placeholder='e.g. 1',
        dynamic_source='activeCustomers'
    )
    LIABILITY_ID = FieldInfo(
        'liabilityID', 'Liability ID',
        type=FieldType.INT,
        required=False,
        is_foreign_key=True,
        placeholder='e.g. 1 (Optional)',
    )
    PAID_AMOUNT = FieldInfo(
        'paidAmount', 'Paid Amount (₱)',
        type=FieldType.REAL,
        required=True,
        placeholder='e.g. 300.0',
    )
    PAYMENT_DATETIME = FieldInfo(
        'paymentDateTime', 'Payment Date & Time',
        type=FieldType.DATETIME,
        required=True,
        placeholder='YYYY-MM-DD HH:MM:SS',
    )

    @staticmethod
    def from_internal_name(name: str) -> 'PaymentField':
        for field in PaymentField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')

    @staticmethod
    def get_fields() -> dict[str, FieldInfo]:
        return {field.value.internal_name: field.value for field in PaymentField}

ENTITY_ENUM_MAP = {
    'unit':      UnitField,
    'customer':  CustomerField,
    'rent':      RentField,
    'liability': LiabilityField,
    'payment':   PaymentField,
}

def get_entity_schema_map():
    return {
        entity_name: [field.value.to_dict() for field in enum_class]
        for entity_name, enum_class in ENTITY_ENUM_MAP.items()
    }

def get_filtered_fields(entity_name: Optional[str] = None, return_attr: Optional[str] = None, **filters) -> List[Any]:
    """
    Filters FieldInfo objects based on their attributes.

    Args:
        entity_name (str, optional): 'unit', 'customer', 'rent', 'liability', 'payment'. 
                                     If None, searches across all entities.
        return_attr (str, optional): A specific attribute to return (e.g., 'internal_name'). 
                                     If None, returns the entire FieldInfo object.
        **filters: Key-value pairs matching FieldInfo attributes (e.g., type=FieldType.FILE).

    Returns:
        List of matching FieldInfo objects or their specific attributes.
    """
    enums_to_search = []
    if entity_name:
        if entity_name not in ENTITY_ENUM_MAP:
            raise ValueError(f'Unknown entity: {entity_name}')
        enums_to_search.append(ENTITY_ENUM_MAP[entity_name])
    else:
        enums_to_search = list(ENTITY_ENUM_MAP.values())
        
    results = []
    for entity_enum in enums_to_search:
        for field in entity_enum:
            field_info: FieldInfo = field.value
            match = True
            for key, value in filters.items():
                if not hasattr(field_info, key) or getattr(field_info, key) != value:
                    match = False
                    break
            if match:
                if return_attr:
                    results.append(getattr(field_info, return_attr))
                else:
                    results.append(field_info)
                    
    return results