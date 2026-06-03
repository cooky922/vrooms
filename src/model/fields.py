from dataclasses import dataclass
from enum import Enum
from typing import Optional


@dataclass(frozen=True)
class FieldInfo:
    internal_name: str
    display_name:  str
    required:      bool = True
    max_length:    Optional[int] = None


class CustomerField(Enum):
    CUSTOMER_ID            = FieldInfo('customer_id',            'Customer ID',              required=True,  max_length=50)
    FIRST_NAME             = FieldInfo('first_name',             'First Name',               required=True,  max_length=100)
    LAST_NAME              = FieldInfo('last_name',              'Last Name',                required=True,  max_length=100)
    REGISTRATION_DATE      = FieldInfo('registration_date',      'Registration Date',        required=True)
    DRIVER_LICENSE_ID      = FieldInfo('driver_license_id',      'Driver License ID',        required=True,  max_length=100)
    DRIVER_LICENSE_PICTURE = FieldInfo('driver_license_picture', 'Driver License Picture',   required=False)
    HOME_ADDRESS           = FieldInfo('home_address',           'Home Address',             required=False, max_length=255)
    CONTACT_NUMBER         = FieldInfo('contact_number',         'Contact Number',           required=True,  max_length=20)

    @staticmethod
    def from_internal_name(name: str) -> 'CustomerField':
        for field in CustomerField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')


class UnitField(Enum):
    PLATE_NUMBER      = FieldInfo('plate_number',      'Plate Number',      required=True,  max_length=20)
    UNIT_MODEL        = FieldInfo('unit_model',        'Unit Model',        required=True,  max_length=100)
    UNIT_STATUS       = FieldInfo('unit_status',       'Unit Status',       required=True)
    DAILY_RATE        = FieldInfo('daily_rate',        'Daily Rate',        required=True)
    UNIT_PICTURE      = FieldInfo('unit_picture',      'Unit Picture',      required=False)
    REGISTRATION_DATE = FieldInfo('registration_date', 'Registration Date', required=True)

    @staticmethod
    def from_internal_name(name: str) -> 'UnitField':
        for field in UnitField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')


class RentField(Enum):
    RENTAL_ID               = FieldInfo('rental_id',               'Rental ID',              required=True, max_length=50)
    CUSTOMER_ID             = FieldInfo('customer_id',             'Customer ID',            required=True, max_length=50)
    PLATE_NUMBER            = FieldInfo('plate_number',            'Plate Number',           required=True, max_length=20)
    RENTAL_STATUS           = FieldInfo('rental_status',           'Rental Status',          required=True)
    RESERVE_DATE            = FieldInfo('reserve_date',            'Reserve Date',           required=True)
    RENTAL_DATE_TIME        = FieldInfo('rental_date_time',        'Rental Date & Time',     required=True)
    EXPECTED_RETURN_DATE    = FieldInfo('expected_return_date',    'Expected Return Date',   required=True)
    ACTUAL_RETURN_DATE_TIME = FieldInfo('actual_return_date_time', 'Actual Return Date/Time',required=False)
    RENTAL_BASE_COST        = FieldInfo('rental_base_cost',        'Rental Base Cost',       required=True)

    @staticmethod
    def from_internal_name(name: str) -> 'RentField':
        for field in RentField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')


class PaymentField(Enum):
    PAYMENT_ID        = FieldInfo('payment_id',        'Payment ID',        required=True, max_length=50)
    RENTAL_ID         = FieldInfo('rental_id',         'Rental ID',         required=True, max_length=50)
    PAYMENT_TYPE      = FieldInfo('payment_type',      'Payment Type',      required=True)
    PAYMENT_DATE_TIME = FieldInfo('payment_date_time', 'Payment Date/Time', required=True)
    AMOUNT_PAID       = FieldInfo('amount_paid',       'Amount Paid',       required=True)

    @staticmethod
    def from_internal_name(name: str) -> 'PaymentField':
        for field in PaymentField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')


class LiabilityField(Enum):
    LIABILITY_ID     = FieldInfo('liability_id',     'Liability ID',     required=True, max_length=50)
    RENTAL_ID        = FieldInfo('rental_id',        'Rental ID',        required=True, max_length=50)
    LIABILITY_STATUS = FieldInfo('liability_status', 'Liability Status', required=True)
    LIABILITY_TYPE   = FieldInfo('liability_type',   'Liability Type',   required=True, max_length=100)
    LIABILITY_FEE    = FieldInfo('liability_fee',    'Liability Fee',    required=True)

    @staticmethod
    def from_internal_name(name: str) -> 'LiabilityField':
        for field in LiabilityField:
            if field.value.internal_name == name:
                return field
        raise ValueError(f'Unknown field: {name}')