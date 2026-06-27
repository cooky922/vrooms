import math
from datetime import datetime
from PyQt6.QtCore import QObject, QUrl, pyqtSlot, pyqtProperty, pyqtSignal
from src.database import Filter, Paged, Sorted, Search, SearchMatchType, SQLDatabase
from src.model import (
    EntityKind,
    FieldInfo,
    FieldType,
    ValidationError,
    DatabaseError,
    CustomerRepository,
    UnitRepository,
    RentRepository,
    PaymentRepository,
    LiabilityRepository,
    REPOSITORY_MAP,
    get_filtered_fields
)
from src.model.validators import (
    UNIT_STATUS_OPTIONS,
    UNIT_STATUS_OPTIONS_EDITABLE,
    CUSTOMER_STATUS_OPTIONS,
    RENT_STATUS_OPTIONS,
    LIABILITY_STATUS_OPTIONS
)

ENTITY_KIND_MAP = {
    'customer':  EntityKind.CUSTOMER,
    'unit':      EntityKind.UNIT,
    'rent':      EntityKind.RENT,
    'payment':   EntityKind.PAYMENT,
    'liability': EntityKind.LIABILITY,
}


class QMLDataViewController(QObject):
    selectedEntityChanged = pyqtSignal()
    paginationChanged     = pyqtSignal()
    sortStateChanged      = pyqtSignal()
    searchChanged         = pyqtSignal()

    def __init__(self, table_model, parent=None):
        super().__init__(parent)
        self.table_model = table_model
        self.entity_kind = EntityKind.UNIT

        self._page_index          = 0
        self._page_size           = 10
        self._visible_item_count  = 0
        self._total_item_count    = 0

        self._filter_options      = {}

        self._sort_field_index    = 0
        self._sort_ascending      = True

        self._search_text         = ''
        self._search_filter_index = 0
        self._search_match_type   = SearchMatchType.CONTAINS

        self.refreshTable()

    # ── Properties ────────────────────────────────────────────────────────────

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
    def searchMatchType(self): return self._search_match_type.value

    @pyqtProperty('QVariantMap', notify=selectedEntityChanged)
    def dynamicOptions(self):
        options_map = {}
        
        # Helper to format simple string arrays into the {value, text} structure
        def format_simple(opts):
            return [{"value": opt, "text": opt} for opt in opts]
        
        if self.entity_kind == EntityKind.UNIT:
            options_map['unitStatus'] = format_simple(UNIT_STATUS_OPTIONS_EDITABLE)
            
        elif self.entity_kind == EntityKind.CUSTOMER:
            options_map['customerStatus'] = format_simple(CUSTOMER_STATUS_OPTIONS)
            
        elif self.entity_kind == EntityKind.RENT:
            options_map['rentStatus'] = format_simple(RENT_STATUS_OPTIONS)
            
            # Fetch Available Units for Rent
            units = SQLDatabase.fetch_all("SELECT unitID, unitBrand, unitModel FROM units WHERE unitStatus = 'Available'")
            options_map['unitID'] = [{"value": str(u['unitID']), "text": f"{u['unitID']} - {u['unitBrand']} {u['unitModel']}"} for u in units]
            
            # Fetch Eligible Customers for Rent
            customers = SQLDatabase.fetch_all("SELECT customerID, firstName, lastName FROM customers")
            eligible_customers = []
            for c in customers:
                is_eligible, _ = CustomerRepository.check_eligibility(c['customerID'])
                if is_eligible:
                    eligible_customers.append({"value": str(c['customerID']), "text": f"{c['customerID']} - {c['firstName']} {c['lastName']}"})
            options_map['customerID'] = eligible_customers
            
        elif self.entity_kind == EntityKind.LIABILITY:
            options_map['liabilityStatus'] = format_simple(LIABILITY_STATUS_OPTIONS)
            
            # Fetch Customers with NO pending liabilities
            customers = SQLDatabase.fetch_all("""
                SELECT c.customerID, c.firstName, c.lastName 
                FROM customers c
                WHERE NOT EXISTS (
                    SELECT 1 FROM liabilities l 
                    WHERE l.customerID = c.customerID AND l.liabilityStatus = 'Pending'
                )
            """)
            options_map['customerID'] = [{"value": str(c['customerID']), "text": f"{c['customerID']} - {c['firstName']} {c['lastName']}"} for c in customers]
            
        elif self.entity_kind == EntityKind.PAYMENT:
            # For Payments, any customer with an outstanding balance
            customers = SQLDatabase.fetch_all("SELECT customerID, firstName, lastName FROM customers")
            debt_customers = []
            for c in customers:
                balance = CustomerRepository.get_balance(c['customerID'])
                if balance > 0:
                    debt_customers.append({"value": str(c['customerID']), "text": f"{c['customerID']} - {c['firstName']} {c['lastName']} (₱{balance:,.2f})"})
            options_map['customerID'] = debt_customers

        return options_map
    # ── Slots ─────────────────────────────────────────────────────────────────

    @pyqtSlot(str, result='QVariantMap')
    def dynamicOptionsFor(self, entity_name: str):
        """
        Return the same options map as dynamicOptions but for any entity,
        regardless of what entity the main table is currently showing.
        Called by AddDialog when it is opened for a different entity
        than the one currently selected in the workspace (e.g. opening
        the 'rent' add-dialog while the main table shows 'unit').
        """
        kind = ENTITY_KIND_MAP.get(entity_name.lower(), self.entity_kind)
        # Temporarily swap entity_kind so the shared helper works, then restore
        saved = self.entity_kind
        self.entity_kind = kind
        result = self.dynamicOptions          # property reads self.entity_kind
        self.entity_kind = saved
        return result

    @pyqtSlot(str)
    def reselectEntity(self, entity_name: str):
        if self.selectedEntityName != entity_name:
            self.entity_kind       = ENTITY_KIND_MAP.get(entity_name, EntityKind.UNIT)
            self._page_index       = 0
            self._sort_field_index = 0
            self._sort_ascending   = True
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
        self._search_text         = ''
        self._search_filter_index = 0
        self._search_match_type   = SearchMatchType.CONTAINS
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
    def setSearchMatchType(self, index: int):
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
    def setFilterOption(self, field_key: str, value: str):
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
    def setSortOptions(self, field_index: int, ascending: bool):
        if self._sort_field_index != field_index or self._sort_ascending != ascending:
            self._sort_field_index = field_index
            self._sort_ascending   = ascending
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

    # ── Validation ────────────────────────────────────────────────────────────

    @pyqtSlot('QVariantMap', 'QVariantMap', str, result='QVariantMap')
    def validateRecord(self, initial_data, current_data, mode):
        """Validate using self.entity_kind (main table entity)."""
        return self._validate(initial_data, current_data, mode, self.entity_kind)

    @pyqtSlot('QVariantMap', 'QVariantMap', str, str, result='QVariantMap')
    def validateRecordFor(self, initial_data, current_data, mode, entity_name):
        """Validate against a specific entity regardless of what the main table shows."""
        kind = ENTITY_KIND_MAP.get(entity_name.lower(), self.entity_kind)
        return self._validate(initial_data, current_data, mode, kind)

    def _validate(self, initial_data, current_data, mode, entity_kind):
        """Core validation logic, entity-kind agnostic."""
        entity_model = entity_kind.get_model()
        repo         = REPOSITORY_MAP[entity_kind]
        primary_key  = repo.get_primary_key()
        fk_fields    = {repo.PARENT_FK} if repo.PARENT_FK else set()

        errors    = {}
        is_valid  = True
        parent_id = current_data.get(repo.PARENT_FK) if repo.PARENT_FK else None

        for col in repo.get_columns():
            if mode == 'add' and primary_key and col == primary_key:
                continue
            val = current_data.get(col, '')

            # Field-level validation (required, format, range, etc.)
            try:
                field = entity_model.from_internal_name(col)
                repo.validate_field(field, val)
            except ValidationError as e:
                errors[col] = e.message
                is_valid    = False
                continue

            # Duplicate primary-key check — never run on FK columns
            if col != primary_key or col in fk_fields:
                continue

            if mode == 'edit':
                if str(current_data.get(primary_key)) != str(initial_data.get(primary_key)):
                    errors[col] = (
                        f'{entity_model.from_internal_name(primary_key).value.display_name} '
                        f'cannot be changed.'
                    )
                    is_valid = False
            else:
                try:
                    repo.check_duplicate_key(val, parent_id=parent_id)
                except DatabaseError as e:
                    errors[col] = e.message
                    is_valid    = False

        return {'isValid': is_valid, 'errors': errors}

    # ── CRUD ──────────────────────────────────────────────────────────────────

    @pyqtSlot(str, str, result='QVariantMap')
    def getRecordByKey(self, key, parent_id=''):
        return REPOSITORY_MAP[self.entity_kind].get_record(
            key, parent_id=parent_id if parent_id else None
        ) or {}

    @pyqtSlot('QVariantMap', result='QVariantMap')
    def addRecord(self, new_data):
        """Add using self.entity_kind (main table entity)."""
        try:
            REPOSITORY_MAP[self.entity_kind].add_record(self.normalizeRecord(new_data))
            return {'success': True, 'message': 'One item added successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot(str, 'QVariantMap', result='QVariantMap')
    def addRecordFor(self, entity_name: str, new_data):
        """Add a record to the correct entity regardless of what the main table shows."""
        kind = ENTITY_KIND_MAP.get(entity_name.lower(), self.entity_kind)
        repo = REPOSITORY_MAP[kind]
        try:
            repo.add_record(self.normalizeRecordFor(new_data, kind))
            return {'success': True, 'message': 'One item added successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot('QVariantMap', 'QVariantMap', result='QVariantMap')
    def updateRecord(self, old_data, new_data):
        """Update using self.entity_kind (main table entity)."""
        try:
            repo          = REPOSITORY_MAP[self.entity_kind]
            primary_key   = self.getPrimaryKey()
            old_key_value = str(old_data[primary_key])
            parent_id     = str(old_data[repo.PARENT_FK]) if repo.PARENT_FK else None

            repo.update_record(self.normalizeRecord(new_data), key=old_key_value, parent_id=parent_id)
            return {'success': True, 'message': 'One item updated successfully.'}
        except Exception as e:
            return {'success': False, 'message': str(e)}
        finally:
            self.refreshTable()

    @pyqtSlot(str, 'QVariantMap', 'QVariantMap', result='QVariantMap')
    def updateRecordFor(self, entity_name: str, old_data, new_data):
        """Update a record for the correct entity regardless of what the main table shows."""
        kind        = ENTITY_KIND_MAP.get(entity_name.lower(), self.entity_kind)
        repo        = REPOSITORY_MAP[kind]
        primary_key = repo.get_primary_key()
        try:
            old_key_value = str(old_data[primary_key])
            parent_id     = str(old_data[repo.PARENT_FK]) if repo.PARENT_FK else None
            repo.update_record(self.normalizeRecordFor(new_data, kind), key=old_key_value, parent_id=parent_id)
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
            repo        = REPOSITORY_MAP[self.entity_kind]
            primary_key = self.getPrimaryKey()
            key_value   = str(old_data[primary_key])
            parent_id   = str(old_data[repo.PARENT_FK]) if repo.PARENT_FK else None

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

    # ── View dialog helpers ───────────────────────────────────────────────────

    @pyqtSlot(str, result='QVariantList')
    def getPaymentsForCustomer(self, customer_id: str):
        if not customer_id:
            return []
        try:
            return PaymentRepository.get_records(parent_id=customer_id)
        except Exception:
            return []

    @pyqtSlot(str, result='QVariantList')
    def getLiabilitiesForCustomer(self, customer_id: str):
        if not customer_id:
            return []
        try:
            return LiabilityRepository.get_records(parent_id=customer_id)
        except Exception:
            return []

    @pyqtSlot(str, result='QVariantList')
    def getRentsForCustomer(self, customer_id: str):
        if not customer_id:
            return []
        try:
            return RentRepository.get_records(
                filter_opt=Filter.By(options={'customerID': customer_id})
            )
        except Exception:
            return []

    @pyqtSlot(str, result='QVariantMap')
    def getActiveRentForUnit(self, unit_id: str):
        if not unit_id:
            return {}
        try:
            rents = RentRepository.get_records(
                filter_opt=Filter.By(options={'unitID': unit_id, 'rentStatus': 'Ongoing'})
            )
            return rents[0] if rents else {}
        except Exception:
            return {}

    @pyqtSlot(str, str, result='QVariantMap')
    def returnUnit(self, rent_id: str, unit_status: str):
        try:
            rent = RentRepository.get_record(rent_id)
            if not rent:
                return {'success': False, 'message': f'Rent "{rent_id}" not found.', 'customerID': ''}

            customer_id = rent.get('customerID') or ''
            unit_id     = rent.get('unitID') or ''

            now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            RentRepository.update_record(
                updates={**rent, 'rentStatus': 'Closed', 'actualReturnDateTime': now},
                key=rent_id
            )

            unit = UnitRepository.get_record(unit_id)
            if unit:
                UnitRepository.update_record(
                    updates={**unit, 'unitStatus': unit_status},
                    key=unit_id
                )

            self.refreshTable()
            return {'success': True, 'message': 'Unit returned successfully.', 'customerID': customer_id}

        except Exception as e:
            return {'success': False, 'message': str(e), 'customerID': ''}

    # ── Internal ──────────────────────────────────────────────────────────────

    def normalizeRecord(self, data: dict) -> dict:
        return self.normalizeRecordFor(data, self.entity_kind)

    def normalizeRecordFor(self, data: dict, kind: EntityKind) -> dict:
        repo     = REPOSITORY_MAP[kind]
        new_data = {}
        for k, v in data.items():
            if k in get_filtered_fields(return_attr='internal_name', type=FieldType.REAL):
                new_data[k] = float(v) if (v is not None and v != '') else None
            elif v is None or v == '':
                new_data[k] = None
            elif k in get_filtered_fields(return_attr='internal_name', type=FieldType.FILE) and isinstance(v, QUrl):
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
                field          = columns[self._search_filter_index - 1]
                search_request = Search(text=text, field=field, match_type=self._search_match_type)

        paged_request  = Paged.Specific(index=self._page_index + 1, size=self._page_size)
        sorted_request = Sorted.By(column=columns[self._sort_field_index], ascending=self._sort_ascending)
        filter_request = Filter.By(options=self._filter_options)

        self._total_item_count = REPOSITORY_MAP[self.entity_kind].get_count(
            search=search_request,
            filter_opt=filter_request,
        )

        entries = REPOSITORY_MAP[self.entity_kind].get_records(
            search=search_request,
            sorted=sorted_request,
            paged=paged_request,
            filter_opt=filter_request,
        )

        self.table_model.resetModel(self.entity_kind, entries)
        self._visible_item_count = len(entries)
        self.paginationChanged.emit()