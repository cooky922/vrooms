from enum import Enum

class EntityKind(Enum):
    CUSTOMER  = 'Customer'
    UNIT      = 'Unit'
    RENT      = 'Rent'
    PAYMENT   = 'Payment'
    LIABILITY = 'Liability'

    def get_model(self):
        from .fields import (
            CustomerField, UnitField, RentField, PaymentField, LiabilityField
        )
        return {
            EntityKind.CUSTOMER:  CustomerField,
            EntityKind.UNIT:      UnitField,
            EntityKind.RENT:      RentField,
            EntityKind.PAYMENT:   PaymentField,
            EntityKind.LIABILITY: LiabilityField,
        }[self]

    def get_parent(self):
        # Weak entities have a parent; strong entities return None
        return {
            EntityKind.PAYMENT:   EntityKind.RENT,
            EntityKind.LIABILITY: EntityKind.RENT,
        }.get(self, None)