import ctypes
import os
import sys
import random
from datetime import datetime

from pathlib import Path
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QIcon
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtWidgets import QApplication

from src.controller import QMLDataViewController
from src.database import SQLDatabase
from src.model import (
    get_entity_schema_map,
    DataTableModel,
    UnitRepository, 
    CustomerRepository, 
    RentRepository, 
    PaymentRepository, 
    LiabilityRepository
)
from src.view.theme import FontLoader, QMLAppTheme
from src.utils import QMLUtils

class App(QApplication):
    windows_app_id = 'ccc151.vrooms.desktop_app.0_1'
    app_qml_file_path = str(Path(__file__).parent.parent / 'src' / 'view' / 'MainWindow.qml')
    app_icon_file_path = str(Path(__file__).parent.parent / 'assets' / 'icons' / 'app-logo.svg')

    def __init__(self):
        # TODO: Load Database First
        SQLDatabase.initialize()
        # App.seedData()

        super().__init__([])

        # Setup app identity for QSettings
        self.setOrganizationName('ccc151')
        self.setApplicationName('vrooms')

        # "Bare metal" Windows Initialization
        os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Basic'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(App.windows_app_id)

        # QML Application Engine
        self.engine = QQmlApplicationEngine()
        self.engine.warnings.connect(App.warningHandler)

        # Load Fonts
        FontLoader.initialize()

        # Set Window Icon
        self.setWindowIcon(QIcon(App.app_icon_file_path))

        # Creating context objects
        self.appTheme = QMLAppTheme(self)
        self.appUtils = QMLUtils(self)
        self.appDataTableModel = DataTableModel(self)
        self.appDataViewController = QMLDataViewController(self.appDataTableModel, self)
        self.appEntitySchemaMap = get_entity_schema_map()

        # Prepare QML context properties and load file
        context = self.engine.rootContext()
        context.setContextProperty('appTheme', self.appTheme)
        context.setContextProperty('appUtils', self.appUtils)
        context.setContextProperty('appDataTableModel', self.appDataTableModel)
        context.setContextProperty('appDataViewController', self.appDataViewController)
        context.setContextProperty('appEntitySchemaMap', self.appEntitySchemaMap)
        self.engine.load(QUrl.fromLocalFile(App.app_qml_file_path))

        # Return early if invalid (ex: QML errors)
        if not self.engine.rootObjects():
            self.exitApp(-1)

    def run(self):
        ret = self.exec()
        self.exitApp(ret)

    def exitApp(self, return_code : int):
        sys.exit(return_code)

    @staticmethod
    def warningHandler(warnings):
        for w in warnings:
            print(f'File: {w.url().toString()}')
            print(f'Line: {w.line()}, Column: {w.column()}')
            print(f'Error: {w.description()}')
        print('--------------------------\n')

    @staticmethod
    def seedData():
        makes = ["TOYOTA", "HONDA", "MITSUBISHI", "HYUNDAI", "ISUZU"]
        series = ["VIOS", "CITY", "MIRAGE", "ACCENT", "D-MAX"]
        bodies = ["SEDAN", "SUV", "HATCHBACK"]
        first_names = ["Juan", "Maria", "Jose", "Andres", "Gabriela", "Antonio", "Emilio", "Apolinario", "Gregoria", "Melchora"]
        last_names = ["Dela Cruz", "Clara", "Rizal", "Bonifacio", "Silang", "Luna", "Aguinaldo", "Mabini", "De Jesus", "Aquino"]

        unit_keys = []
        cust_keys = []
        # Store rental info as objects to allow matching payment amounts
        rent_records = [] 

        # Format: YYYY-MM-DD (Time removed)
        today_date = datetime.now().strftime("%Y-%m-%d")
        rental_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # 1. GENERATE 10 UNITS
        for i in range(10):
            plate = f"ABC-{100 + i}"
            model_str = f"{random.choice(makes)} {random.choice(series)} {random.choice(bodies)} - 2024"
            
            unit_data = {
                "plateNumber": plate,
                "unitModel": model_str,
                "unitPicture": "default.jpg",
                "unitStatus": "Available",
                "dailyRate": float(random.randint(1000, 3000)), # Variation
                "registrationDate": today_date
            }
            UnitRepository.add_record(unit_data)
            unit_keys.append(plate)

        # 2. GENERATE 10 CUSTOMERS
        for i in range(10):
            cust_data = {
                "firstName": first_names[i],
                "lastName": last_names[i],
                "contactNumber": f"09170000{100 + i}",
                "homeAddress": f"{i+1} Main St, Iligan City",
                "driverLicenseID": f"LIC-{500 + i}",
                "driverLicenseIDPicture": "lic.jpg",
                "customerStatus": "Active",
                "registrationDate": today_date # Time removed
            }
            CustomerRepository.add_record(cust_data)
            cust_keys.append(i + 1) 

        # 3. GENERATE 5 RENTALS
        for i in range(5):
            base_cost = float(random.randint(2000, 6000)) # Variation
            rent_data = {
                "customerID": cust_keys[i],
                "unitPlateNumber": unit_keys[i],
                "rentalStatus": "Active",
                "rentalDateTime": rental_time,
                "expectedReturnDateTime": "2026-06-10 18:00:00",
                "rentalBaseCost": base_cost
            }
            RentRepository.add_record(rent_data)
            # Store ID and cost so we can match the payment amount later
            rent_records.append({"id": i + 1, "cost": base_cost})

        # 4. GENERATE 5 PAYMENTS
        for i in range(5):
            pay_data = {
                "rentalID": rent_records[i]["id"],
                "amountPaid": rent_records[i]["cost"], # Paid exactly the base cost
                "paymentDateTime": rental_time,
                "paymentType": "Base Fee" 
            }
            PaymentRepository.add_record(pay_data)

        print("Database seeded successfully with varied costs and clean dates.")