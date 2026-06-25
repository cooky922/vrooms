from PyQt6.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot
from src.database.database import SQLDatabase
from src.model import CustomerRepository, UnitRepository, RentRepository

class QMLDashboardController(QObject):
    dataChanged = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._total_customers = 0
        self._total_units     = 0
        self._total_rents     = 0
        
        self._units_by_status_data     = []
        self._customers_by_status_data = []
        self._rents_by_status_data     = []

    @pyqtProperty(int, notify=dataChanged)
    def totalCustomers(self): return self._total_customers

    @pyqtProperty(int, notify=dataChanged)
    def totalUnits(self): return self._total_units

    @pyqtProperty(int, notify=dataChanged)
    def totalRents(self): return self._total_rents

    @pyqtProperty('QVariantList', notify=dataChanged)
    def unitsByStatusData(self): return self._units_by_status_data
    
    @pyqtProperty('QVariantList', notify=dataChanged)
    def customersByStatusData(self): return self._customers_by_status_data

    @pyqtProperty('QVariantList', notify=dataChanged)
    def rentsByStatusData(self): return self._rents_by_status_data

    @pyqtSlot()
    def refreshData(self):
        self._total_customers = CustomerRepository.get_count()
        self._total_units     = UnitRepository.get_count()
        self._total_rents     = RentRepository.get_count()

        self._units_by_status_data = SQLDatabase.fetch_all(
            "SELECT unitStatus AS label, COUNT(*) AS value FROM units GROUP BY unitStatus"
        ) or []
        
        self._customers_by_status_data = SQLDatabase.fetch_all(
            "SELECT customerStatus AS label, COUNT(*) AS value FROM customers GROUP BY customerStatus"
        ) or []

        self._rents_by_status_data = SQLDatabase.fetch_all(
            "SELECT rentStatus AS label, COUNT(*) AS value FROM rents GROUP BY rentStatus"
        ) or []

        self.dataChanged.emit()