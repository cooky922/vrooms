import ctypes
import os
import sys
from pathlib import Path
from PyQt6.QtCore import QUrl
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtWidgets import QApplication

class App(QApplication):
    windows_app_id = 'ccc151.vrooms.desktop_app.0_1'
    app_qml_file_path = str(Path(__file__).parent.parent / 'src' / 'view' / 'MainWindow.qml')

    def __init__(self):
        # TODO: Load Database First
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

        # TODO: Load Fonts

        # TODO: Set Window Icon

        # TODO: Creating context objects

        # TODO: Prepare QML context properties and load file
        context = self.engine.rootContext()
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