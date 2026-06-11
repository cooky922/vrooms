from dataclasses import dataclass
from enum import Enum
from typing import Optional

@dataclass(frozen=True)
class FieldInfo:
    internal_name: str
    display_name:  str
    required:      bool = True
    max_length:    Optional[int] = None

class UnitField(Enum):
    PLATE_NUMBER      = FieldInfo('plateNumber',      'Plate Number',      required=True,  max_length=15)
    UNIT_MODEL        = FieldInfo('unitModel',        'Model',             required=True,  max_length=50)
    UNIT_PICTURE      = FieldInfo('unitPicture',      'Picture',           required=False, max_length=255)
    UNIT_STATUS       = FieldInfo('unitStatus',       'Status',            required=True)
    DAILY_RATE        = FieldInfo('dailyRate',        'Daily Rate',        required=True)
    REGISTRATION_DATE = FieldInfo('registrationDate', 'Start Date',        required=True)

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
    CUSTOMER_ID            = FieldInfo('customerID',             'ID',              required=True)
    FIRST_NAME             = FieldInfo('firstName',              'First Name',               required=True,  max_length=50)
    LAST_NAME              = FieldInfo('lastName',               'Last Name',                required=True,  max_length=50)
    CONTACT_NUMBER         = FieldInfo('contactNumber',          'Contact Number',           required=True,  max_length=11)
    HOME_ADDRESS           = FieldInfo('homeAddress',            'Home Address',             required=True,  max_length=255)
    DRIVER_LICENSE_ID      = FieldInfo('driverLicenseID',        'Driver License ID',        required=True,  max_length=15)
    DRIVER_LICENSE_PICTURE = FieldInfo('driverLicenseIDPicture', 'Driver License Picture',   required=True,  max_length=255)
    CUSTOMER_STATUS        = FieldInfo('customerStatus',         'Status',          required=True)
    REGISTRATION_DATE      = FieldInfo('registrationDate',       'Start Date',        required=True)

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
    RENTAL_ID               = FieldInfo('rentalID',               'ID',                      required=True)
    CUSTOMER_ID             = FieldInfo('customerID',             'Customer ID',             required=True)
    UNIT_PLATE_NUMBER       = FieldInfo('unitPlateNumber',        'Unit Plate Number',       required=True, max_length=15)
    RENTAL_STATUS           = FieldInfo('rentalStatus',           'Status',                  required=True)
    RENTAL_DATE_TIME        = FieldInfo('rentalDateTime',         'Rental Date & Time',      required=True)
    EXPECTED_RETURN_DATE    = FieldInfo('expectedReturnDateTime', 'Expected Return Date',    required=True)
    ACTUAL_RETURN_DATE_TIME = FieldInfo('actualReturnDateTime',   'Actual Return Date & Time', required=False)
    RENTAL_BASE_COST        = FieldInfo('rentalBaseCost',         'Rental Base Cost',        required=True)

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
    PAYMENT_ID        = FieldInfo('paymentID',       'ID',                required=True)
    RENTAL_ID         = FieldInfo('rentalID',        'Rental ID',         required=True)
    AMOUNT_PAID       = FieldInfo('amountPaid',      'Amount Paid',       required=True)
    PAYMENT_DATE_TIME = FieldInfo('paymentDateTime', 'Payment Date & Time', required=True)
    PAYMENT_TYPE      = FieldInfo('paymentType',     'Payment Type',      required=True)

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
    LIABILITY_ID     = FieldInfo('liabilityID',     'ID',               required=True)
    RENTAL_ID        = FieldInfo('rentalID',        'Rental ID',        required=True)
    LIABILITY_TYPE   = FieldInfo('liabilityType',   'Liability Type',   required=True)
    LIABILITY_FEE    = FieldInfo('liabilityFee',    'Liability Fee',    required=True)
    LIABILITY_STATUS = FieldInfo('liabilityStatus', 'Status',           required=True)

    @staticmethod
    def from_internal_name(name: str) -> 'LiabilityField':
        for field in LiabilityField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')

    @staticmethod
    def get_fields() -> dict[str, FieldInfo]:
        return {field.value.internal_name: field.value for field in LiabilityField}