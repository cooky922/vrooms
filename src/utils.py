from PyQt6.QtCore import QObject, pyqtSlot, pyqtProperty, pyqtSignal # type: ignore
from PyQt6.QtGui import QColor # type: ignore
from datetime import datetime

class QMLUtils(QObject):
    def __init__(self, parent = None):
        super().__init__(parent)

    @pyqtSlot(str, result = bool)
    def printLog(self, msg):
        print(msg)
        return True

    @pyqtSlot(str, bool, bool, result = str)
    def calculateColor(self, color, is_hovered, is_pressed):
        qcolor = QColor(color)
        is_light_color = qcolor.lightness() >= 150
        if is_hovered:
            return (qcolor.darker(110) if is_light_color else qcolor.lighter(110)).name()
        elif is_pressed:
            return (qcolor.darker(120) if is_light_color else qcolor.lighter(120)).name()
        else:
            return color

    @pyqtSlot(str, float, result = str)
    def colorWithAlpha(self, color, alpha_float):
        qcolor = QColor(color)
        
        # convert the float (0.0 - 1.0) to an integer (0 - 255)
        alpha_int = max(0, min(255, int(alpha_float * 255)))
        qcolor.setAlpha(alpha_int)
        
        # return in #AARRGGBB format which QML reads natively
        return qcolor.name(QColor.NameFormat.HexArgb)

    @pyqtSlot(str, result = str)
    def prettifyColumnName(self, name):
        return name.replace('_', ' ').title()

    @pyqtSlot(str, result = str)
    def renameEntityName(self, name):
        entityNames = {
            'Units': 'unit',
            'Customers': 'customer',
            'Rents': 'rent',
            'Payments': 'payment',
            'Liabilities': 'liability'
        }
        return entityNames.get(name, '')

    @pyqtSlot(str, result = str)
    def capitalize(self, s):
        return s.capitalize()

    @pyqtSlot(str, result=str)
    def formatDate(self, db_string):
        """Converts 'YYYY-MM-DD' to 'YYYY Month DD' (e.g. 2027 June 5)"""
        if not db_string or db_string.strip() == "": 
            return ""
        try:
            d_str = db_string.split(" ")[0] # Safely extract just the date part
            dt = datetime.strptime(d_str, "%Y-%m-%d")
            return f"{dt.year} {dt.strftime('%B')} {dt.day}"
        except Exception as e:
            print(f"Date Parse Error: {e}")
            return db_string # Fallback to raw string if error

    @pyqtSlot(str, result=str)
    def formatDateTime(self, db_string):
        """Converts 'YYYY-MM-DD HH:MM:SS' to 'YYYY Month DD | h:mm:ss AM/PM'"""
        if not db_string or db_string.strip() == "": 
            return ""
        try:
            # Handle potential cases where seconds are missing
            if db_string.count(':') == 1:
                dt = datetime.strptime(db_string, "%Y-%m-%d %H:%M")
            else:
                dt = datetime.strptime(db_string, "%Y-%m-%d %H:%M:%S")
                
            date_part = f"{dt.year} {dt.strftime('%B')} {dt.day}"
            # int(strftime('%I')) automatically strips the leading zero for 1-9 hours
            time_part = f"{int(dt.strftime('%I'))}:{dt.strftime('%M:%S')} {dt.strftime('%p')}"
            
            return f"{date_part} | {time_part}"
        except Exception as e:
            print(f"DateTime Parse Error: {e}")
            return db_string