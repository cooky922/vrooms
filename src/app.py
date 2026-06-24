import ctypes
import os
import sys
import random
from datetime import datetime, timedelta

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
        # Load Database First
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
        makes = ["TOYOTA", "HONDA", "MITSUBISHI", "HYUNDAI", "ISUZU", "FORD", "NISSAN", "SUZUKI"]
        series = ["VIOS", "CITY", "MIRAGE", "ACCENT", "D-MAX", "RANGER", "NAVARA", "SWIFT", "INNOVA", "HIACE"]
        bodies = ["SEDAN", "SUV", "HATCHBACK", "PICKUP", "MPV"]
        first_names = ["Juan", "Maria", "Jose", "Andres", "Gabriela", "Antonio", "Emilio", "Apolinario", "Gregoria", "Melchora", "Carlos", "Luis", "Carmen", "Teresa", "Manuel", "Rosario", "Francisco", "Elena", "Pedro", "Clara"]
        last_names = ["Dela Cruz", "Clara", "Rizal", "Bonifacio", "Silang", "Luna", "Aguinaldo", "Mabini", "De Jesus", "Aquino", "Garcia", "Reyes", "Ramos", "Mendoza", "Santos", "Flores", "Gonzales", "Bautista", "Villanueva", "Fernandez"]

        now = datetime.now()
        today_date = now.strftime("%Y-%m-%d")

        unit_keys = []
        cust_keys = []

        # 1. GENERATE 25 UNITS WITH VARIED STATUSES
        for i in range(25):
            plate = f"ABC-{100 + i}"
            model_str = f"{random.choice(makes)} {random.choice(series)} {random.choice(bodies)} - 202{random.randint(0, 4)}"
            
            # Organic Status Distribution
            rand_val = random.random()
            if rand_val < 0.60:
                status = 'Available'
            elif rand_val < 0.90:
                status = 'Rented'
            else:
                status = 'Maintenance'
                
            unit_data = {
                "plateNumber": plate,
                "unitModel": model_str,
                "unitPicture": "", # Null/Empty Image Path
                "unitStatus": status,
                "dailyRate": float(random.randint(15, 45) * 100), 
                "registrationDate": today_date
            }
            UnitRepository.add_record(unit_data)
            # Store the auto-incremented unitID (i + 1) for foreign key relations later
            unit_keys.append({"unitID": i + 1, "status": status})

        # 2. GENERATE 25 CUSTOMERS WITH VARIED STATUSES
        for i in range(25):
            rand_val = random.random()
            if rand_val < 0.8:
                status = 'Active'
            elif rand_val < 0.9:
                status = 'Suspended'
            else:
                status = 'Blacklisted'

            cust_data = {
                "firstName": first_names[i % len(first_names)],
                "lastName": last_names[i % len(last_names)],
                "phoneNumber": f"0917{str(random.randint(1000000, 9999999))}", # Updated from contactNumber
                "homeAddress": f"{i+1} Main St, Iligan City",
                "driverLicenseID": f"LIC-{5000 + i}",
                "driverLicenseIDPicture": "", # Null/Empty Image Path
                "customerStatus": status,
                "registrationDate": today_date 
            }
            CustomerRepository.add_record(cust_data)
            cust_keys.append(i + 1) 

        # 3. GENERATE LOGICALLY LINKED RENTS, PAYMENTS & LIABILITIES
        rent_id_counter = 1
        
        for u in unit_keys:
            u_id = u['unitID'] # Linking via unitID now
            u_status = u['status']
            c_id = random.choice(cust_keys)
            
            base_cost = float(random.randint(2000, 8000))
            
            rental_start_date = now - timedelta(days=random.randint(1, 30))
            rental_time = rental_start_date.strftime("%Y-%m-%d %H:%M:%S")
            
            if u_status == 'Rented':
                expected_return = (now + timedelta(days=random.randint(1, 5))).strftime("%Y-%m-%d %H:%M:%S")
                
                RentRepository.add_record({
                    "customerID": c_id,
                    "unitID": u_id, # Updated key
                    "rentStatus": "Active", # Updated from rentalStatus
                    "rentDateTime": rental_time, # Updated from rentalDateTime
                    "expectedReturnDate": expected_return, # Updated from expectedReturnDateTime
                    "rentBaseCost": base_cost, # Updated from rentalBaseCost
                    "actualReturnDateTime": None
                })
                
                # Add Payment for the Active Rental
                PaymentRepository.add_record({
                    "rentID": rent_id_counter, # Updated from rentalID
                    "amountPaid": base_cost,
                    "paymentDateTime": rental_time,
                    "paymentType": "Base Fee"
                })
                rent_id_counter += 1
                
            elif u_status in ['Available', 'Maintenance']:
                past_status = random.choice(['Completed', 'Completed', 'Cancelled', 'Returned with Liabilities'])
                
                actual_return = (rental_start_date + timedelta(days=random.randint(1, 3))).strftime("%Y-%m-%d %H:%M:%S")
                expected_return = (rental_start_date + timedelta(days=random.randint(2, 4))).strftime("%Y-%m-%d %H:%M:%S")
                
                RentRepository.add_record({
                    "customerID": c_id,
                    "unitID": u_id,
                    "rentStatus": past_status,
                    "rentDateTime": rental_time,
                    "expectedReturnDate": expected_return,
                    "rentBaseCost": base_cost,
                    "actualReturnDateTime": actual_return if past_status != 'Cancelled' else None
                })
                
                if past_status != 'Cancelled':
                    PaymentRepository.add_record({
                        "rentID": rent_id_counter,
                        "amountPaid": base_cost,
                        "paymentDateTime": rental_time,
                        "paymentType": "Base Fee"
                    })
                    
                # Simulate a Liability scenario
                if past_status == 'Returned with Liabilities':
                    lia_fee = float(random.randint(500, 5000))
                    lia_status = random.choice(['Active', 'Cleared'])
                    
                    LiabilityRepository.add_record({
                        "rentID": rent_id_counter,
                        "liabilityType": random.choice(['Overdue', 'Damage', 'Equipment Loss', 'Other']),
                        "liabilityFee": lia_fee,
                        "liabilityStatus": lia_status
                    })
                    
                    # If cleared, generate a corresponding Liability payment
                    if lia_status == 'Cleared':
                        PaymentRepository.add_record({
                            "rentID": rent_id_counter,
                            "amountPaid": lia_fee, 
                            "paymentDateTime": actual_return,
                            "paymentType": "Liability Fee"
                        })
                    
                rent_id_counter += 1

        print("Database seeded successfully with updated schema column names.")