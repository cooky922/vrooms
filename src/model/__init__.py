from .errors import ValidationError, DatabaseError
from .entity_kind import EntityKind
from .repositories import (
    CustomerRepository,
    UnitRepository,
    RentRepository,
    PaymentRepository,
    LiabilityRepository,
)

REPOSITORY_MAP = {
    EntityKind.CUSTOMER:  CustomerRepository,
    EntityKind.UNIT:      UnitRepository,
    EntityKind.RENT:      RentRepository,
    EntityKind.PAYMENT:   PaymentRepository,
    EntityKind.LIABILITY: LiabilityRepository,
}