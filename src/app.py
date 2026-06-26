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

from src.controller import QMLDataViewController, QMLDashboardController
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
from src.controller.dynamic_options import QMLDynamicOptions  # Dynamic dropdown options for QML

class App(QApplication):
    windows_app_id = 'ccc151.vrooms.desktop_app.0_1'
    app_qml_file_path = str(Path(__file__).parent.parent / 'src' / 'view' / 'MainWindow.qml')
    app_icon_file_path = str(Path(__file__).parent.parent / 'assets' / 'icons' / 'app-logo.svg')

    def __init__(self):
        # TODO: Load Database First
        SQLDatabase.initialize()
        #App.seedData()

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
        self.appDashboardController = QMLDashboardController(self)
        self.appDashboardController.refreshData()
        self.appEntitySchemaMap = get_entity_schema_map()
        self.appDynamicOptions = QMLDynamicOptions(self)  # Provides live dropdown data to QML

        # Prepare QML context properties and load file
        context = self.engine.rootContext()
        context.setContextProperty('appTheme', self.appTheme)
        context.setContextProperty('appUtils', self.appUtils)
        context.setContextProperty('appDataTableModel', self.appDataTableModel)
        context.setContextProperty('appDataViewController', self.appDataViewController)
        context.setContextProperty('appDashboardController', self.appDashboardController)
        context.setContextProperty('appEntitySchemaMap', self.appEntitySchemaMap)
        context.setContextProperty('appDynamicOptions', self.appDynamicOptions)  # Expose to QML
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
        brands = ["Honda", "Yamaha", "Suzuki", "Kawasaki", "KTM", "Vespa"]
        models = ["Click 125i", "NMAX", "Raider R150", "Ninja 400", "Duke 390", "PCX 160", "Aerox", "Sniper 155"]
        colors = ["Matte Black", "Pearl White", "Racing Blue", "Fiery Red", "Metallic Silver"]
        
        first_names = ["Juan", "Maria", "Jose", "Andres", "Gabriela", "Antonio", "Emilio", "Apolinario", "Gregoria", "Melchora", "Carlos", "Luis", "Carmen", "Teresa", "Manuel", "Rosario", "Francisco", "Elena", "Pedro", "Clara"]
        last_names = ["Dela Cruz", "Clara", "Rizal", "Bonifacio", "Silang", "Luna", "Aguinaldo", "Mabini", "De Jesus", "Aquino", "Garcia", "Reyes", "Ramos", "Mendoza", "Santos", "Flores", "Gonzales", "Bautista", "Villanueva", "Fernandez"]

        now = datetime.now()
        today_date = now.strftime("%Y-%m-%d")

        unit_keys = []
        cust_keys = []

        # 1. GENERATE 25 UNITS WITH VARIED STATUSES
        for i in range(25):
            plate = f"ABC{100 + i}"
            daily_rate = float(random.randint(15, 45) * 100)
            
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
                "unitBrand": random.choice(brands),
                "unitModel": random.choice(models),
                "unitColor": random.choice(colors),
                "unitYear": random.randint(2018, 2024),
                "unitPicture": "",
                "unitStatus": status,
                "dailyRate": daily_rate, 
                "dateAdded": today_date
            }
            UnitRepository.add_record(unit_data)
            # Store properties needed for mathematical rent calculation later
            unit_keys.append({
                "unitID": i + 1, 
                "status": status, 
                "dailyRate": daily_rate
            })

        # 2. GENERATE 25 CUSTOMERS WITH VARIED STATUSES
        for i in range(25):
            f_name = first_names[i % len(first_names)]
            l_name = last_names[i % len(last_names)]
            
            # 90% Active, 10% Blacklisted
            status = 'Active' if random.random() < 0.9 else 'Blacklisted'
            
            # Ensure license expiry is in the future for eligibility
            expiry_date = (now + timedelta(days=random.randint(100, 1500))).strftime("%Y-%m-%d")

            cust_data = {
                "firstName": f_name,
                "lastName": l_name,
                "phoneNumber": f"0917{str(random.randint(1000000, 9999999))}",
                "emailAddress": f"{f_name.lower()}.{l_name.lower()}{i}@example.com",
                "homeAddress": f"{i+1} Main St, Iligan City",
                "profilePicture": "", 
                "driverLicenseID": f"D02-24-{random.randint(100000, 999999)}",
                "driverLicenseIDPicture": "",
                "driverLicenseExpiryDate": expiry_date,
                "customerStatus": status,
                "dateRegistered": today_date 
            }
            CustomerRepository.add_record(cust_data)
            cust_keys.append(i + 1) 

        # 3. GENERATE LOGICALLY LINKED RENTS, LIABILITIES & PAYMENTS
        liability_id_counter = 0
        
        for u in unit_keys:
            u_id = u['unitID']
            u_status = u['status']
            daily_rate = u['dailyRate']
            c_id = random.choice(cust_keys)
            
            rental_start_date = now - timedelta(days=random.randint(1, 30))
            rent_time = rental_start_date.strftime("%Y-%m-%d %H:%M:%S")
            
            # Strict Constraint: rentDateTime <= expectedReturnDateTime <= rentDateTime + 7 Days
            days_rented = random.randint(1, 7)
            expected_return_date = rental_start_date + timedelta(days=days_rented)
            expected_return = expected_return_date.strftime("%Y-%m-%d %H:%M:%S")
            
            # Locked Checkout Fee: dailyRate * totalDays
            locked_rent_fee = float(daily_rate * days_rented)
            
            if u_status == 'Rented':
                # Rented unit must have an 'Ongoing' rental
                RentRepository.add_record({
                    "customerID": c_id,
                    "unitID": u_id,
                    "rentStatus": "Ongoing", 
                    "rentDateTime": rent_time,
                    "expectedReturnDateTime": expected_return, 
                    "actualReturnDateTime": None,
                    "rentFee": locked_rent_fee
                })
                
                # Record base rent payment (Linked to customerID, Liability is NULL)
                PaymentRepository.add_record({
                    "customerID": c_id,
                    "liabilityID": None,
                    "paidAmount": locked_rent_fee,
                    "paymentDateTime": rent_time
                })
                
            elif u_status in ['Available', 'Maintenance']:
                # Past rentals are Closed
                actual_return_date = rental_start_date + timedelta(days=random.randint(1, days_rented))
                actual_return = actual_return_date.strftime("%Y-%m-%d %H:%M:%S")
                
                RentRepository.add_record({
                    "customerID": c_id,
                    "unitID": u_id,
                    "rentStatus": "Closed",
                    "rentDateTime": rent_time,
                    "expectedReturnDateTime": expected_return,
                    "actualReturnDateTime": actual_return,
                    "rentFee": locked_rent_fee
                })
                
                # Base rent payment made at the start of the rental
                PaymentRepository.add_record({
                    "customerID": c_id,
                    "liabilityID": None,
                    "paidAmount": locked_rent_fee,
                    "paymentDateTime": rent_time
                })
                
                if u_status == 'Maintenance':
                    # Maintenance unit -> Customer damaged it -> Issue a Pending Liability
                    liability_id_counter += 1
                    lia_fee = float(random.randint(500, 5000))
                    
                    LiabilityRepository.add_record({
                        "customerID": c_id, # Linked to customer, not rent!
                        "liabilityDescription": random.choice(["Scratched fairings", "Broken side mirror", "Flat tire"]),
                        "liabilityFee": lia_fee,
                        "liabilityStatus": "Pending",
                        "issuedDateTime": actual_return
                    })
                    # Note: No payment made yet because status is Pending
                    
                else: # Available
                    # 20% chance they had a liability that was Settled
                    if random.random() < 0.2:
                        liability_id_counter += 1
                        lia_fee = float(random.randint(200, 1000))
                        
                        LiabilityRepository.add_record({
                            "customerID": c_id,
                            "liabilityDescription": random.choice(["Late return fee", "Lost helmet"]),
                            "liabilityFee": lia_fee,
                            "liabilityStatus": "Settled",
                            "issuedDateTime": actual_return
                        })
                        
                        # They settled it, so we create a payment referencing the liabilityID
                        payment_time = (actual_return_date + timedelta(hours=2)).strftime("%Y-%m-%d %H:%M:%S")
                        PaymentRepository.add_record({
                            "customerID": c_id,
                            "liabilityID": liability_id_counter, # Payment linked specifically to this liability
                            "paidAmount": lia_fee, 
                            "paymentDateTime": payment_time
                        })

        print("Database seeded successfully with document-compliant ERD linkage.")