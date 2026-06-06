from .errors import ValidationError
from .fields import (
    CustomerField, UnitField, RentField, PaymentField, LiabilityField
)

UNIT_STATUS_OPTIONS      = ['Available', 'Rented', 'Maintenance']
CUSTOMER_STATUS_OPTIONS  = ['Active', 'Suspended', 'Blacklisted']
RENTAL_STATUS_OPTIONS    = ['Cancelled', 'Active', 'Returned with Liabilities', 'Completed']
PAYMENT_TYPE_OPTIONS     = ['Base Fee', 'Liability Fee']
LIABILITY_TYPE_OPTIONS   = ['Overdue', 'Damage', 'Equipment Loss', 'Other']
LIABILITY_STATUS_OPTIONS = ['Active', 'Cleared']

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

def validate_unit_field(field: UnitField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == UnitField.UNIT_STATUS and value not in UNIT_STATUS_OPTIONS:
        raise ValidationError(f'Unit Status must be one of: {", ".join(UNIT_STATUS_OPTIONS)}.')
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
    if field == RentField.RENTAL_STATUS and value not in RENTAL_STATUS_OPTIONS:
        raise ValidationError(f'Rental Status must be one of: {", ".join(RENTAL_STATUS_OPTIONS)}.')
    if field == RentField.RENTAL_BASE_COST:
        try:
            if float(value) < 0:
                raise ValidationError('Rental Base Cost must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Rental Base Cost must be a valid number.')

def validate_payment_field(field: PaymentField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == PaymentField.PAYMENT_TYPE and value not in PAYMENT_TYPE_OPTIONS:
        raise ValidationError(f'Payment Type must be one of: {", ".join(PAYMENT_TYPE_OPTIONS)}.')
    if field == PaymentField.AMOUNT_PAID:
        try:
            if float(value) < 0:
                raise ValidationError('Amount Paid must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Amount Paid must be a valid number.')

def validate_liability_field(field: LiabilityField, value):
    info = field.value
    _require_nonempty(value, info)
    _max_length(value, info)
    if field == LiabilityField.LIABILITY_STATUS and value not in LIABILITY_STATUS_OPTIONS:
        raise ValidationError(f'Liability Status must be one of: {", ".join(LIABILITY_STATUS_OPTIONS)}.')
    if field == LiabilityField.LIABILITY_TYPE and value not in LIABILITY_TYPE_OPTIONS:
        raise ValidationError(f'Liability Type must be one of: {", ".join(LIABILITY_TYPE_OPTIONS)}.')
    if field == LiabilityField.LIABILITY_FEE:
        try:
            if float(value) < 0:
                raise ValidationError('Liability Fee must be a non-negative number.')
        except (TypeError, ValueError):
            raise ValidationError('Liability Fee must be a valid number.')