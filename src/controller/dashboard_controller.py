from PyQt6.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from src.database.database import SQLDatabase
from src.model import CustomerRepository, UnitRepository, RentRepository


class QMLDashboardController(QObject):
    dataChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._total_customers        = 0
        self._total_units            = 0
        self._total_rents            = 0
        self._active_rents           = 0
        self._available_units        = 0
        self._units_by_status_data   = []
        self._rents_by_status_data   = []
        self._revenue_by_customer    = []
        self._top_rented_units       = []

    @pyqtProperty(int, notify=dataChanged)
    def totalCustomers(self): return self._total_customers

    @pyqtProperty(int, notify=dataChanged)
    def totalUnits(self): return self._total_units

    @pyqtProperty(int, notify=dataChanged)
    def totalRents(self): return self._total_rents

    @pyqtProperty(int, notify=dataChanged)
    def activeRents(self): return self._active_rents

    @pyqtProperty(int, notify=dataChanged)
    def availableUnits(self): return self._available_units

    @pyqtProperty('QVariantList', notify=dataChanged)
    def unitsByStatusData(self): return self._units_by_status_data

    @pyqtProperty('QVariantList', notify=dataChanged)
    def rentsByStatusData(self): return self._rents_by_status_data

    @pyqtProperty('QVariantList', notify=dataChanged)
    def revenueByCustomerData(self): return self._revenue_by_customer

    @pyqtProperty('QVariantList', notify=dataChanged)
    def topRentedUnitsData(self): return self._top_rented_units

    @pyqtSlot()
    def refreshData(self):
        self._total_customers = CustomerRepository.get_count()
        self._total_units     = UnitRepository.get_count()
        self._total_rents     = RentRepository.get_count()

        self._active_rents    = SQLDatabase.fetch_scalar(
            "SELECT COUNT(*) FROM rents WHERE rental_status = 'Active'"
        ) or 0

        self._available_units = SQLDatabase.fetch_scalar(
            "SELECT COUNT(*) FROM units WHERE unit_status = 'Available'"
        ) or 0

        self._units_by_status_data = SQLDatabase.fetch_all(
            "SELECT unit_status AS label, COUNT(*) AS value FROM units GROUP BY unit_status"
        ) or []

        self._rents_by_status_data = SQLDatabase.fetch_all(
            "SELECT rental_status AS label, COUNT(*) AS value FROM rents GROUP BY rental_status"
        ) or []

        self._revenue_by_customer = SQLDatabase.fetch_all("""
            SELECT c.customer_id AS label,
                   SUM(r.rental_base_cost) AS value
            FROM rents r
            JOIN customers c ON r.customer_id = c.customer_id
            GROUP BY c.customer_id
            ORDER BY value DESC
            LIMIT 10
        """) or []

        self._top_rented_units = SQLDatabase.fetch_all("""
            SELECT plate_number AS label, COUNT(*) AS value
            FROM rents
            GROUP BY plate_number
            ORDER BY value DESC
            LIMIT 10
        """) or []

        self.dataChanged.emit()