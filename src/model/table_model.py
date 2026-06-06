from PyQt6.QtCore import Qt, QAbstractTableModel, QModelIndex, pyqtSlot, pyqtProperty

from .entity_kind import EntityKind
from .repositories import REPOSITORY_MAP

class RecordTableModel(QAbstractTableModel):
    def __init__(self, parent = None):
        super().__init__(parent)
        self._entity_kind = EntityKind.UNIT
        self._headers = REPOSITORY_MAP[self._entity_kind].get_columns()
        self._data = [] # This data holds only the exact rows for the current page

    def resetModel(self, entity_kind, data : list[dict] = None):
        self.beginResetModel()
        self._entity_kind = entity_kind
        self._headers = REPOSITORY_MAP[entity_kind].get_columns()
        self._data = data if data is not None else []
        self.endResetModel()
    
    def rowCount(self, parent = QModelIndex()):
        return len(self._data)
    
    def columnCount(self, parent = QModelIndex()):
        return len(self._headers)
    
    def data(self, index, role = Qt.ItemDataRole.DisplayRole):
        if not index.isValid():
            return None
        if role == Qt.ItemDataRole.DisplayRole:
            row = index.row()
            col = index.column()
            key = self._headers[col]
            value = self._data[row].get(key, '')
            return None if value is None else str(value)
        return None
    
    def headerData(self, section, orientation, role = Qt.ItemDataRole.DisplayRole):
        if role == Qt.ItemDataRole.DisplayRole and orientation == Qt.Orientation.Horizontal:
            val = REPOSITORY_MAP[self._entity_kind].FIELD_ENUM.get_fields()[self._headers[section]]
            return val.display_name
        return None
    
    @pyqtSlot(int, result = 'QVariantMap')
    def getRowData(self, row):
        if 0 <= row < len(self._data):
            return self._data[row]
        else:
            return {}

    @pyqtSlot(int, str, result=int)
    def getColumnWidth(self, column, entity_name):
        kind_map = {
            'Customer': EntityKind.CUSTOMER, 
            'Unit': EntityKind.UNIT, 
            'Rent': EntityKind.RENT,
            'Payment': EntityKind.PAYMENT, 
            'Liability': EntityKind.LIABILITY
        }
        kind = kind_map.get(entity_name, EntityKind.UNIT)
        columns = REPOSITORY_MAP[kind].get_columns()
        
        if column < 0 or column >= len(columns):
            return 100
            
        col_key = columns[column]
        fields_info = REPOSITORY_MAP[kind].FIELD_ENUM.get_fields()
        header_text = fields_info[col_key].display_name
        
        # Start with header width
        max_len = len(header_text)
        
        # Compare with data (only if data exists)
        if self._data:
            for record in self._data:
                val = str(record.get(col_key, ''))
                if len(val) > max_len:
                    max_len = len(val)
        
        return max(80, min((max_len * 10) + 30, 300))