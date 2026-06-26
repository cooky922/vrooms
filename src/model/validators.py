import re

from .errors import ValidationError
from .fields import *

PLATE_NUMBER_PATTERN      = re.compile(r'^(?=.*[A-Z])(?=.*[0-9])[A-Z0-9]{6}$')
DRIVER_LICENSE_ID_PATTERN = re.compile(r'^[A-Z]\d{2}-\d{2}-\d{6}$')
PHONE_NUMBER_PATTERN      = re.compile(r'^09\d{9}$')

def _require_nonempty(value, field_info):
    if field_info.required and (value is None or str(value).strip() == ''):
        raise ValidationError(f'{field_info.display_name} is required.')

def _max_length(value, field_info):
    if value is not None and field_info.max_length and len(str(value)) > field_info.max_length:
        raise ValidationError(
            f'{field_info.display_name} must not exceed {field_info.max_length} characters.'
        )

def validate_customer_field(field: CustomerField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == CustomerField.CUSTOMER_STATUS and value not in CUSTOMER_STATUS_OPTIONS:
        raise ValidationError(f'Customer Status must be one of: {", ".join(CUSTOMER_STATUS_OPTIONS)}.')
    if field == CustomerField.PHONE_NUMBER and value and not PHONE_NUMBER_PATTERN.match(str(value)):
        raise ValidationError('Phone Number must follow the format: 09XXXXXXXXX (11 digits, starting with 09).')
    if field == CustomerField.DRIVER_LICENSE_ID and value and not DRIVER_LICENSE_ID_PATTERN.match(str(value)):
        raise ValidationError('Driver License ID must follow the format: C10-17-123456 (letter, 2 digits, 2 digits, 6 digits).')

def validate_unit_field(field: UnitField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == UnitField.UNIT_STATUS and value not in UNIT_STATUS_OPTIONS:
        raise ValidationError(f'Unit Status must be one of: {", ".join(UNIT_STATUS_OPTIONS)}.')
    if field == UnitField.PLATE_NUMBER and value and not PLATE_NUMBER_PATTERN.match(str(value)):
        raise ValidationError('Plate Number must be 6 characters, a mix of uppercase letters and numbers (e.g. 123ABC or A12B34).')
    if field == UnitField.DAILY_RATE:
        try:
            if float(value) < 0:
                raise ValidationError('Daily Rate must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Daily Rate must be a valid number.')

def validate_rent_field(field: RentField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == RentField.RENT_STATUS and value not in RENT_STATUS_OPTIONS:
        raise ValidationError(f'Rent Status must be one of: {", ".join(RENT_STATUS_OPTIONS)}.')
    if field == RentField.RENT_FEE:
        try:
            if float(value) < 0:
                raise ValidationError('Rent Fee must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Rent Fee must be a valid number.')

def validate_payment_field(field: PaymentField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == PaymentField.PAID_AMOUNT:
        try:
            if float(value) < 0:
                raise ValidationError('Paid amount must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Paid amount must be a valid number.')

def validate_liability_field(field: LiabilityField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == LiabilityField.LIABILITY_STATUS and value not in LIABILITY_STATUS_OPTIONS:
        raise ValidationError(f'Liability Status must be one of: {", ".join(LIABILITY_STATUS_OPTIONS)}.')
    if field == LiabilityField.LIABILITY_FEE:
        try:
            if float(value) < 0:
                raise ValidationError('Liability Fee must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Liability Fee must be a valid number.')