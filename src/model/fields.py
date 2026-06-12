from dataclasses import dataclass, asdict
from enum import Enum
from typing import Optional, List, Dict, Any

UNIT_STATUS_OPTIONS      = ['Available', 'Rented', 'Maintenance']
CUSTOMER_STATUS_OPTIONS  = ['Active', 'Suspended', 'Blacklisted']
RENTAL_STATUS_OPTIONS    = ['Cancelled', 'Active', 'Returned with Liabilities', 'Completed']
PAYMENT_TYPE_OPTIONS     = ['Base Fee', 'Liability Fee']
LIABILITY_TYPE_OPTIONS   = ['Overdue', 'Damage', 'Equipment Loss', 'Other']
LIABILITY_STATUS_OPTIONS = ['Active', 'Cleared']

class FieldType(Enum):
    TEXT = 'text'
    REAL = 'real'
    INT  = 'int'
    DATE = 'date'
    DATETIME = 'datetime'
    FILE = 'file'
    SELECT = 'select'

@dataclass(frozen=True)
class FieldInfo:
    internal_name: str
    display_name:  str
    type:          FieldType
    required:      bool = True
    is_primary_key: bool = False
    is_foreign_key: bool = False
    placeholder:   Optional[str] = None
    options:       Optional[List[str]] = None
    max_length:    Optional[int] = None

    def to_dict(self) -> Dict[str, Any]:
        data = {
            'key': self.internal_name,
            'label': self.display_name,
            'type': self.type.value,
            'required': self.required,
            'is_primary_key': self.is_primary_key,
            'is_foreign_key': self.is_foreign_key
        }
        if self.placeholder is not None:
            data['placeholder'] = self.placeholder
        if self.options is not None:
            data['options'] = self.options
        if self.max_length is not None:
            data['max_length'] = self.max_length
        return data

class UnitField(Enum):
    PLATE_NUMBER = FieldInfo(
        'plateNumber', 'Plate Number',
        type = FieldType.TEXT, 
        required = True,
        is_primary_key = True,
        placeholder = 'e.g. ABC-1234', 
        max_length = 15
    )
    UNIT_MODEL = FieldInfo(
        'unitModel', 'Model',
        type = FieldType.TEXT, 
        required = True,
        placeholder = 'e.g. Toyota Camry', 
        max_length = 50
    )
    UNIT_STATUS = FieldInfo(
        'unitStatus', 'Status',
        type = FieldType.SELECT,
        required = True, 
        options = UNIT_STATUS_OPTIONS
    )
    DAILY_RATE = FieldInfo(
        'dailyRate', 'Daily Rate (₱)',
        type = FieldType.REAL, 
        required = True, 
        placeholder = 'e.g. 300.0'
    )
    UNIT_PICTURE = FieldInfo(
        'unitPicture', 'Picture',
        type = FieldType.FILE, 
        required = False, 
        max_length = 255
    )
    REGISTRATION_DATE = FieldInfo(
        'registrationDate', 'Start Date',
        type = FieldType.DATE, 
        required = True,
        placeholder = 'YYYY-MM-DD'
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
        type = FieldType.INT,
        required = True,
        is_primary_key = True,
        placeholder = 'e.g. 1',
    )
    FIRST_NAME = FieldInfo(
        'firstName', 'First Name',
        type = FieldType.TEXT, 
        required = True,
        placeholder = 'e.g. Juan', 
        max_length = 50
    )
    LAST_NAME = FieldInfo(
        'lastName', 'Last Name',
        type = FieldType.TEXT,
        required = True,
        placeholder = 'e.g. Dela Cruz',
        max_length = 50
    )
    CUSTOMER_STATUS = FieldInfo(
        'customerStatus', 'Status',
        type = FieldType.SELECT,
        required = True,
        options = CUSTOMER_STATUS_OPTIONS
    )
    CONTACT_NUMBER = FieldInfo(
        'contactNumber', 'Contact Number',
        type = FieldType.TEXT,
        required = True,
        placeholder = 'e.g. 09123456789',
        max_length = 11
    )
    HOME_ADDRESS = FieldInfo(
        'homeAddress', 'Home Address',
        type = FieldType.TEXT,
        required = True,
        placeholder = 'e.g. 123 Main St',
        max_length = 255
    )
    DRIVER_LICENSE_ID = FieldInfo(
        'driverLicenseID', 'Driver License ID',
        type = FieldType.TEXT,
        required = True,
        placeholder = 'e.g. DL-0001',
        max_length = 15
    )
    DRIVER_LICENSE_PICTURE = FieldInfo(
        'driverLicenseIDPicture', 'Driver License Picture',
        type = FieldType.FILE,
        required = False,
        max_length = 255
    )
    REGISTRATION_DATE = FieldInfo(
        'registrationDate', 'Start Date',
        type = FieldType.DATE,
        required = True,
        placeholder = 'YYYY-MM-DD'
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
    RENTAL_ID = FieldInfo(
        'rentalID', 'ID',
        type = FieldType.INT,
        required = True,
        is_primary_key = True,
        placeholder = 'e.g. 1'
    )
    CUSTOMER_ID = FieldInfo(
        'customerID', 'Customer ID',
        type = FieldType.INT,
        required = True,
        is_foreign_key = True,
        placeholder = 'e.g. 1'
    )
    UNIT_PLATE_NUMBER = FieldInfo(
        'unitPlateNumber', 'Unit Plate Number',
        type = FieldType.TEXT,
        required = True,
        is_foreign_key = True,
        placeholder = 'e.g. ABC-1234', 
        max_length = 15
    )
    RENTAL_STATUS = FieldInfo(
        'rentalStatus', 'Status',
        type = FieldType.SELECT,
        required = True,
        options = RENTAL_STATUS_OPTIONS
    )
    RENTAL_DATETIME = FieldInfo(
        'rentalDateTime', 'Rental Date & Time',
        type = FieldType.DATETIME,
        required = True,
        placeholder = 'YYYY-MM-DD HH:MM:SS'
    )
    EXPECTED_RETURN_DATETIME = FieldInfo(
        'expectedReturnDateTime', 'Expected Return Date & Time',
        type = FieldType.DATETIME,
        required = True,
        placeholder = 'YYYY-MM-DD HH:MM:SS'
    )
    ACTUAL_RETURN_DATETIME = FieldInfo(
        'actualReturnDateTime', 'Actual Return Date & Time',
        type = FieldType.DATETIME,
        required = False,
        placeholder = 'YYYY-MM-DD HH:MM:SS'
    )
    RENTAL_BASE_COST = FieldInfo(
        'rentalBaseCost', 'Rental Base Cost (₱)',
        type = FieldType.REAL,
        required = True,
        placeholder = 'e.g. 1200.0'
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

class PaymentField(Enum):
    PAYMENT_ID = FieldInfo(
        'paymentID', 'ID',
        type = FieldType.INT,
        required = True,
        is_primary_key = True,
        placeholder = 'e.g. 1'
    )
    RENTAL_ID = FieldInfo(
        'rentalID', 'Rental ID',
        type = FieldType.INT,
        required = True,
        is_foreign_key = True,
        placeholder = 'e.g. 1'
    )
    AMOUNT_PAID = FieldInfo(
        'amountPaid', 'Amount Paid (₱)',
        type = FieldType.REAL,
        required = True,
        placeholder = 'e.g. 300.0'
    )
    PAYMENT_TYPE = FieldInfo(
        'paymentType', 'Payment Type',
        type = FieldType.SELECT,
        required = True,
        options = PAYMENT_TYPE_OPTIONS
    )
    PAYMENT_DATETIME = FieldInfo(
        'paymentDateTime', 'Payment Date & Time',
        type = FieldType.DATETIME,
        required = True,
        placeholder = 'YYYY-MM-DD HH:MM:SS'
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

class LiabilityField(Enum):
    LIABILITY_ID = FieldInfo(
        'liabilityID', 'ID',
        type = FieldType.INT,
        required = True,
        is_primary_key = True,
        placeholder = 'e.g. 1'
    )
    RENTAL_ID = FieldInfo(
        'rentalID', 'Rental ID',
        type = FieldType.INT,
        required = True,
        is_foreign_key = True,
        placeholder = 'e.g. 1'
    )
    LIABILITY_TYPE = FieldInfo(
        'liabilityType', 'Liability Type',
        type = FieldType.SELECT,
        required = True,
        options = LIABILITY_TYPE_OPTIONS
    )
    LIABILITY_FEE = FieldInfo(
        'liabilityFee', 'Liability Fee (₱)', 
        type = FieldType.REAL,
        required = True,
        placeholder = 'e.g. 300.0'
    )
    LIABILITY_STATUS = FieldInfo(
        'liabilityStatus', 'Status',
        type = FieldType.SELECT,
        required = True,
        options = LIABILITY_STATUS_OPTIONS
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

def get_entity_schema_map():
    return {
        'Unit': [field.value.to_dict() for field in UnitField],
        'Customer': [field.value.to_dict() for field in CustomerField],
        'Rent': [field.value.to_dict() for field in RentField],
        'Payment': [field.value.to_dict() for field in PaymentField],
        'Liability': [field.value.to_dict() for field in LiabilityField]
    }