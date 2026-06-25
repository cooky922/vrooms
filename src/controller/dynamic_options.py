from PyQt6.QtCore import QObject, pyqtSlot
from src.model.repositories import UnitRepository, CustomerRepository


class QMLDynamicOptions(QObject):
    """
    Exposes live-queried dropdown options to QML.
    Registered as `appDynamicOptions` in the QML context.
    """

    def __init__(self, parent=None):
        super().__init__(parent)

    @pyqtSlot(result=list)
    def getAvailableUnits(self) -> list[str]:
        """Returns plate numbers of units with status 'Available'."""
        try:
            records = UnitRepository.get_all_records()
            return [
                r["plateNumber"]
                for r in records
                if r.get("unitStatus") == "Available"
            ]
        except Exception as e:
            print(f"[DynamicOptions] getAvailableUnits error: {e}")
            return []

    @pyqtSlot(result=list)
    def getActiveCustomers(self) -> list[str]:
        """Returns 'ID – First Last' strings for customers with status 'Active'."""
        try:
            records = CustomerRepository.get_all_records()
            return [
                f"{r['customerID']} – {r['firstName']} {r['lastName']}"
                for r in records
                if r.get("customerStatus") == "Active"
            ]
        except Exception as e:
            print(f"[DynamicOptions] getActiveCustomers error: {e}")
            return []
