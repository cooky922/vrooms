import math
from PyQt6.QtCore import QObject, QUrl, pyqtSlot, pyqtProperty, pyqtSignal
from src.database import Filter, Paged, Sorted, Search, SearchMatchType
from src.model import (
    EntityKind,
    ValidationError,
    DatabaseError,
    CustomerRepository,
    UnitRepository,
    RentRepository,
    PaymentRepository,
    LiabilityRepository,
    REPOSITORY_MAP,
)
from src.model.validators import (
    UNIT_STATUS_OPTIONS,
    CUSTOMER_STATUS_OPTIONS,
    RENTAL_STATUS_OPTIONS,
    PAYMENT_TYPE_OPTIONS,
    LIABILITY_STATUS_OPTIONS,
    LIABILITY_TYPE_OPTIONS,
)

class QMLDataViewController(QObject):
    selectedEntityChanged = pyqtSignal()
    paginationChanged     = pyqtSignal()
    sortStateChanged      = pyqtSignal()
    searchChanged         = pyqtSignal()

    def __init__(self, table_model, parent=None):
        super().__init__(parent)
        self.table_model = table_model
        self.entity_kind = EntityKind.UNIT

        self._page_index = 0
        self._page_size = 10
        self._visible_item_count = 0
        self._total_item_count = 0

        self._filter_options = {}

        self._sort_field_index = 0
        self._sort_ascending = True

        self._search_text = ''
        self._search_filter_index = 0
        self._search_match_type = SearchMatchType.CONTAINS

        self.refreshTable()

    # Properties
    @pyqtProperty(int, notify=paginationChanged)
    def totalItemCount(self): return self._total_item_count

    @pyqtProperty(int, notify=paginationChanged)
    def visibleItemCount(self): return self._visible_item_count

    @pyqtProperty(str, notify=selectedEntityChanged)
    def selectedEntityName(self): return self.entity_kind.value

    @pyqtSlot(result=str)
    def getPrimaryKey(self):
        return REPOSITORY_MAP[self.entity_kind].get_primary_key()

    @pyqtProperty(int, notify=paginationChanged)
    def pageIndex(self): return self._page_index

    @pyqtProperty(int, notify=paginationChanged)
    def pageSize(self): return self._page_size

    @pyqtProperty(int, notify=paginationChanged)
    def totalPages(self):
        if self._total_item_count == 0:
            return 1
        return max(1, math.ceil(self._total_item_count / self._page_size))

    @pyqtProperty('QVariantMap', notify=selectedEntityChanged)
    def filterOptions(self): return self._filter_options

    @pyqtProperty(int, notify=sortStateChanged)
    def sortFieldIndex(self): return self._sort_field_index

    @pyqtProperty(bool, notify=sortStateChanged)
    def sortAscending(self): return self._sort_ascending

    @pyqtProperty(str, notify=searchChanged)
    def searchText(self): return self._search_text

    @pyqtProperty(int, notify=searchChanged)
    def searchFilterIndex(self): return self._search_filter_index

    @pyqtProperty(int, notify=searchChanged)
    def searchMatchType(self): 
        return self._search_match_type.value

    @pyqtProperty('QVariantList', notify=selectedEntityChanged)
    def selectedEntityTransformedModel(self):
        fields = self.entity_kind.get_model()
        def get_options(field_name: str):
            match field_name:
                case 'unitStatus':
                    return UNIT_STATUS_OPTIONS
                case 'customerStatus':
                    return CUSTOMER_STATUS_OPTIONS
                case 'rentalStatus':
                    return RENTAL_STATUS_OPTIONS
                case 'paymentType':
                    return PAYMENT_TYPE_OPTIONS
                case 'liabilityStatus':
                    return LIABILITY_STATUS_OPTIONS
                case 'liabilityType':
                    return LIABILITY_TYPE_OPTIONS
                case 'customerID' if self.entity_kind == EntityKind.RENT:
                    return CustomerRepository.get_keys()
                case 'unitPlateNumber' if self.entity_kind == EntityKind.RENT:
                    return UnitRepository.get_keys()
                case 'rentalID' if self.entity_kind in (EntityKind.PAYMENT, EntityKind.LIABILITY):
                    return RentRepository.get_keys()
                case _:
                    return []
        return [{
            'internal_name': f.value.internal_name,
            'display_name':  f.value.display_name,
            'options':       get_options(f.value.internal_name)
        } for f in fields]

    # Slots
    @pyqtSlot(str)
    def reselectEntity(self, entity_name: str):
        if self.selectedEntityName != entity_name:
            kind_map = {
                'customer':  EntityKind.CUSTOMER,
                'unit':      EntityKind.UNIT,
                'rent':      EntityKind.RENT,
                'payment':   EntityKind.PAYMENT,
                'liability': EntityKind.LIABILITY,
            }
            self.entity_kind = kind_map.get(entity_name, EntityKind.UNIT)
            self._page_index = 0
            self._sort_field_index = 0
            self._sort_ascending = True
            self.resetSearchOptions()
            self.resetFilterOptions()
            self.sortStateChanged.emit()
            self.selectedEntityChanged.emit()
            self.refreshTable()

    @pyqtSlot(str)
    def updateSearch(self, text: str):
        if self._search_text != text:
            self._search_text = text
            self._page_index  = 0
            self.searchChanged.emit()
            self.paginationChanged.emit()
            self.refreshTable()

    @pyqtSlot()
    def resetSearchOptions(self):
        self._search_text = ''
        self._search_filter_index = 0
        self._search_match_type = SearchMatchType.CONTAINS
        self.searchChanged.emit()

    @pyqtSlot(int)
    def setSearchFilterIndex(self, index: int):
        if self._search_filter_index != index:
            self._search_filter_index = index
            self.searchChanged.emit()
            if self._search_text.strip():
                self._page_index = 0
                self.refreshTable()

    @pyqtSlot(int)
    def setSearchMatchType(self, index : int):
        new_match_type = SearchMatchType(index) 
        if self._search_match_type != new_match_type:
            self._search_match_type = new_match_type
            self.searchChanged.emit()
            if self._search_text.strip():
                self._page_index = 0
                self.refreshTable()

    def resetFilterOptions(self):
        self._filter_options = {}

    @pyqtSlot(str, str)
    def setFilterOption(self, field_key : str, value : str):
        if value and value != '':
            self._filter_options[field_key] = value
        elif field_key in self._filter_options:
            del self._filter_options[field_key]
        self._page_index = 0
        self.paginationChanged.emit()
        self.refreshTable()

    @pyqtSlot(int)
    def toggleSort(self, field_index: int):
        if self._sort_field_index == field_index:
            self._sort_ascending = not self._sort_ascending
        else:
            self._sort_field_index = field_index
            self._sort_ascending   = True
        self._page_index = 0
        self.sortStateChanged.emit()
        self.paginationChanged.emit()
        self.refreshTable()

    @pyqtSlot(int, bool)
    def setSortOptions(self, field_index : int, ascending: bool):
        if self._sort_field_index != field_index or self._sort_ascending != ascending:
            self._sort_field_index = field_index
            self._sort_ascending = ascending
            self.sortStateChanged.emit()
            self.paginationChanged.emit()
            self.refreshTable()

    @pyqtSlot()
    def nextPage(self):
        if self._page_index < (self.totalPages - 1):
            self._page_index += 1
            self.refreshTable()

    @pyqtSlot()
    def prevPage(self):
        if self._page_index > 0:
            self._page_index -= 1
            self.refreshTable()

    @pyqtSlot()
    def setFirstPage(self):
        if self._page_index > 0:
            self._page_index = 0
            self.refreshTable()

    @pyqtSlot()
    def setLastPage(self):
        if self._page_index < (self.totalPages - 1):
            self._page_index = self.totalPages - 1
            self.refreshTable()

    @pyqtSlot(int)
    def setPage(self, page_number: int):
        target = page_number - 1
        if 0 <= target < self.totalPages:
            self._page_index = target
            self.refreshTable()

    @pyqtSlot(int)
    def setPageSize(self, size: int):
        if self._page_size != size:
            self._page_size  = size
            self._page_index = 0
            self.paginationChanged.emit()
            self.refreshTable()

    @pyqtSlot()
    def resetStates(self):
        self.entity_kind          = EntityKind.UNIT
        self._page_index          = 0
        self._sort_field_index    = 0
        self._sort_ascending      = True
        self.resetSearchOptions()
        self.resetFilterOptions()
        self.sortStateChanged.emit()
        self.selectedEntityChanged.emit()
        self.searchChanged.emit()
        self.refreshTable()

    @pyqtSlot('QVariantMap', 'QVariantMap', result=bool)
    def areRecordsEqual(self, old_data, new_data):
        return old_data == self.normalizeRecord(new_data)

    @pyqtSlot('QVariantMap', 'QVariantMap', str, result='QVariantMap')
    def validateRecord(self, initial_data, current_data, mode):
        entity_model = self.entity_kind.get_model()
        primary_key  = self.getPrimaryKey()
        errors       = {}
        is_valid     = True

        repo = REPOSITORY_MAP[self.entity_kind]
        parent_id = current_data.get(repo.PARENT_FK) if repo.PARENT_FK else None
        
        for col in repo.get_columns():
            val = current_data.get(col, '')
            try:
                field = entity_model.from_internal_name(col)
                repo.validate_field(field, val)
            except ValidationError as e:
                errors[col] = e.message
                is_valid    = False
                continue

            if primary_key and col == primary_key:
                try:
                    if mode == 'edit' and current_data.get(primary_key) == initial_data.get(primary_key):
                        continue
                    repo.check_duplicate_key(val, parent_id=parent_id)
                except DatabaseError as e:
                    errors[col] = e.message
                    is_valid    = False

        return {'isValid': is_valid, 'errors': errors}

    @pyqtSlot(str, str, result='QVariantMap')
    def getRecordByKey(self, key, parent_id=''):
        return REPOSITORY_MAP[self.entity_kind].get_record(key, parent_id=parent_id if parent_id else None) or {}

    @pyqtSlot('QVariantMap', result='QVariantMap')
    def addRecord(self, new_data):
        try:
            REPOSITORY_MAP[self.entity_kind].add_record(self.normalizeRecord(new_data))
            return {'success': True, 'message': 'One item added successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot('QVariantMap', 'QVariantMap', result='QVariantMap')
    def updateRecord(self, old_data, new_data):
        try:
            repo = REPOSITORY_MAP[self.entity_kind]
            primary_key   = self.getPrimaryKey()
            old_key_value = str(old_data[primary_key])
            parent_id     = str(old_data[repo.PARENT_FK]) if repo.PARENT_FK else None
            
            repo.update_record(self.normalizeRecord(new_data), key=old_key_value, parent_id=parent_id)
            return {'success': True, 'message': 'One item updated successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot(list, 'QVariantMap', result='QVariantMap')
    def updateRecords(self, keys, updates):
        try:
            REPOSITORY_MAP[self.entity_kind].update_records(keys, updates)
            return {'success': True, 'message': 'Multiple items updated successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot('QVariantMap', result='QVariantMap')
    def deleteRecord(self, old_data):
        try:
            repo = REPOSITORY_MAP[self.entity_kind]
            primary_key = self.getPrimaryKey()
            key_value = str(old_data[primary_key])
            parent_id = str(old_data[repo.PARENT_FK]) if repo.PARENT_FK else None
            
            repo.delete_record(key=key_value, parent_id=parent_id)
            return {'success': True, 'message': 'One item deleted successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot(list, result='QVariantMap')
    def deleteRecords(self, keys):
        try:
            REPOSITORY_MAP[self.entity_kind].delete_records(keys)
            return {'success': True, 'message': 'Multiple items deleted successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    # Internal methods (cannot be used outside this file)
    def normalizeRecord(self, data: dict) -> dict:
        new_data = {}
        repo     = REPOSITORY_MAP[self.entity_kind]
        for k, v in data.items():
            if k in ('dailyRate', 'rentalBaseCost', 'amountPaid', 'liabilityFee'):
                new_data[k] = float(v) if (v is not None and v != '') else None
            elif v is None or v == '':
                new_data[k] = None
            elif k in ('unitPicture', 'driverLicenseIDPicture') and isinstance(v, QUrl):
                new_data[k] = v.toLocalFile() if v.isLocalFile() else str(v)
            else:
                new_data[k] = str(v)
        for col in repo.get_columns():
            if col not in new_data:
                new_data[col] = None
        return new_data

    def refreshTable(self):
        columns = REPOSITORY_MAP[self.entity_kind].get_columns()

        search_request = None
        if self._search_text:
            text = self._search_text.strip().lower()
            if self._search_filter_index == 0:
                search_request = Search(text=text, match_type=self._search_match_type)
            else:
                field = columns[self._search_filter_index - 1]
                search_request = Search(text=text, field=field, match_type=self._search_match_type)

        paged_request  = Paged.Specific(index=self._page_index + 1, size=self._page_size)
        sorted_request = Sorted.By(column=columns[self._sort_field_index], ascending=self._sort_ascending)
        filter_request = Filter.By(options=self._filter_options)

        self._total_item_count = REPOSITORY_MAP[self.entity_kind].get_count(
            search=search_request, 
            filter_opt=filter_request
        )

        entries = REPOSITORY_MAP[self.entity_kind].get_records(
            search=search_request,
            sorted=sorted_request,
            paged=paged_request,
            filter_opt=filter_request
        )

        self.table_model.resetModel(self.entity_kind, entries)
        self._visible_item_count = len(entries)
        self.paginationChanged.emit()