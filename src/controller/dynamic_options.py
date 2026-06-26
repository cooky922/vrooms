from PyQt6.QtCore import QObject, pyqtSlot
from src.database import SQLDatabase
from src.model.repositories import (
    UnitRepository,
    CustomerRepository,
)


class QMLDynamicOptions(QObject):
    """
    Exposes live-queried dropdown options to QML.
    Registered as `appDynamicOptions` in the QML context.

    dynamic_source keys (mirrors fields.py):
        availableUnits                   -> units with status 'Available'
        eligibleCustomers                -> customers passing all eligibility checks
        allCustomers                     -> all customers regardless of status
        customersWithoutPendingLiability -> customers with no Pending liability
        unitStatusOptions                -> user-selectable unit statuses
        pendingLiabilitiesByCustomer     -> pending liabilities for a chosen customer
    """

    def __init__(self, parent=None):
        super().__init__(parent)

    # ------------------------------------------------------------------
    # Units
    # ------------------------------------------------------------------

    @pyqtSlot(result=list)
    def getAvailableUnits(self) -> list[str]:
        """Plate numbers of units with status 'Available'."""
        try:
            records = UnitRepository.get_records()
            return [
                r['plateNumber']
                for r in records
                if r.get('unitStatus') == 'Available'
            ]
        except Exception as e:
            print(f'[DynamicOptions] getAvailableUnits error: {e}')
            return []

    @pyqtSlot(str, result=list)
    def getUnitStatusOptions(self, current_status: str) -> list[str]:
        """
        Selectable unit statuses for the Edit dialog.
        Returns [] when current status is 'Rented' so QML can lock the field.
        """
        if current_status == 'Rented':
            return []
        return ['Available', 'Maintenance']

    # ------------------------------------------------------------------
    # Customers
    # ------------------------------------------------------------------

    @pyqtSlot(result=list)
    def getEligibleCustomers(self) -> list[str]:
        """
        'ID – First Last' for customers who pass ALL eligibility checks:
          - customerStatus = 'Active'
          - balance = 0
          - driverLicenseExpiryDate > today
          - no ongoing rental
        Used in the Rent add dialog.
        """
        try:
            records = CustomerRepository.get_records()
            result = []
            for r in records:
                ok, _ = CustomerRepository.check_eligibility(r['customerID'])
                if ok:
                    result.append(
                        f"{r['customerID']} \u2013 {r['firstName']} {r['lastName']}"
                    )
            return result
        except Exception as e:
            print(f'[DynamicOptions] getEligibleCustomers error: {e}')
            return []

    @pyqtSlot(result=list)
    def getAllCustomers(self) -> list[str]:
        """'ID – First Last' for ALL customers. Used in Payment add dialog."""
        try:
            records = CustomerRepository.get_records()
            return [
                f"{r['customerID']} \u2013 {r['firstName']} {r['lastName']}"
                for r in records
            ]
        except Exception as e:
            print(f'[DynamicOptions] getAllCustomers error: {e}')
            return []

    @pyqtSlot(result=list)
    def getCustomersWithoutPendingLiability(self) -> list[str]:
        """
        'ID – First Last' for customers who have NO Pending liability.
        Used in the Liability add dialog.
        """
        try:
            rows = SQLDatabase.fetch_all(
                """
                SELECT c.customerID, c.firstName, c.lastName
                FROM customers c
                WHERE c.customerID NOT IN (
                    SELECT DISTINCT customerID
                    FROM liabilities
                    WHERE liabilityStatus = 'Pending'
                )
                """
            )
            return [
                f"{r['customerID']} \u2013 {r['firstName']} {r['lastName']}"
                for r in rows
            ]
        except Exception as e:
            print(f'[DynamicOptions] getCustomersWithoutPendingLiability error: {e}')
            return []

    # ------------------------------------------------------------------
    # Liabilities
    # ------------------------------------------------------------------

    @pyqtSlot(int, result=list)
    def getPendingLiabilitiesByCustomer(self, customer_id: int) -> list[str]:
        """
        'ID – Description (₱fee)' for Pending liabilities of a specific customer.
        Returns [] when customer_id <= 0 (no customer selected yet).
        Used in Payment add dialog for the cascading liabilityID dropdown.
        """
        if customer_id <= 0:
            return []
        try:
            rows = SQLDatabase.fetch_all(
                """
                SELECT liabilityID, liabilityDescription, liabilityFee
                FROM liabilities
                WHERE customerID = ? AND liabilityStatus = 'Pending'
                """,
                (customer_id,)
            )
            return [
                f"{r['liabilityID']} \u2013 {r['liabilityDescription']} (\u20b1{r['liabilityFee']:,.2f})"
                for r in rows
            ]
        except Exception as e:
            print(f'[DynamicOptions] getPendingLiabilitiesByCustomer error: {e}')
            return []

    # ------------------------------------------------------------------
    # Legacy aliases
    # ------------------------------------------------------------------

    @pyqtSlot(result=list)
    def getActiveCustomers(self) -> list[str]:
        """Backward-compat alias for getEligibleCustomers."""
        return self.getEligibleCustomers()