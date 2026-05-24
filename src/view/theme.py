from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from PyQt6.QtGui import QFontDatabase # type: ignore
from PyQt6.QtCore import QObject, pyqtProperty, pyqtSlot, pyqtSignal # type: ignore

class classproperty(object):
    def __init__(self, fget):
        self.fget = fget

    def __get__(self, owner_self, owner_cls):
        return self.fget(owner_cls)

class FontLoader:
    _font_resource_dir = Path(__file__).parent.parent.parent / 'assets' / 'fonts'
    _fonts = {
        'DEFAULT': {
            'family_name' : 'Arial'
        },
        'ROKKITT': {
            # undefined 'family_name' yet
            'path': str(_font_resource_dir / 'Rokkitt' / 'Rokkitt-VariableFont_wght.ttf')
        },
        'RETHINK_SANS': {
            # undefined 'family_name' yet
            'path': str(_font_resource_dir / 'Rethink_Sans' / 'RethinkSans-VariableFont_wght.ttf')
        },
        'INCLUSIVE_SANS': {
            # undefined 'family_name' yet
            'path': str(_font_resource_dir / 'Inclusive_Sans' / 'InclusiveSans-VariableFont_wght.ttf')
        }
    }

    @classmethod
    def hasInitialized(self):
        for _, font_info in self._fonts.items():
            if 'family_name' not in font_info:
                return False
        return True   

    @classmethod
    def initialize(self):
        for _, font_info in self._fonts.items():
            if 'path' in font_info:
                font_path = font_info['path']
                if not Path(font_path).exists():
                    raise FileNotFoundError(f'Font file not found: {font_path}')
                font_id = QFontDatabase.addApplicationFont(font_path)
                if font_id == -1:
                    raise Exception(f'Failed to load font: {font_path}')
                # success
                family_name = QFontDatabase.applicationFontFamilies(font_id)[0]
                font_info.update({ 'family_name': family_name })

    @classmethod
    def getFamilyName(self, key):
        return self._fonts.get(key.upper(), 'DEFAULT')['family_name']

@dataclass(frozen = True, init = False)
class Theme:
    LOGIN_BG_MAIN_COLOR = '#93ADE5'
    LOGIN_BG_MAIN_LAST_COLOR = '#C9D6F2'

    DARK_ONE_COLOR = '#000000'
    DARK_TWO_COLOR = '#333333'
    DARK_THREE_COLOR = '#888888'
    DARK_FOUR_COLOR = '#ECECEC'
    LIGHT_ONE_COLOR = '#FFFFFF'
    LIGHT_TWO_COLOR = '#FAFAFA'
    ACTIVE_COLOR = '#B5DFFF'
    ACTIVE_DARK_COLOR = '#285CCC'
    
    BG_COLOR = LIGHT_TWO_COLOR
    PRIMARY_BUTTON_BG_COLOR = DARK_FOUR_COLOR
    BORDER_COLOR = DARK_THREE_COLOR

    DARKEST_TEXT_COLOR = DARK_ONE_COLOR
    DARK_TEXT_COLOR = DARK_THREE_COLOR

    # Fonts
    _ROKKITT_FONT_NAME = None
    _RETHINK_SANS_FONT_NAME = None
    _INCLUSIVE_SANS_FONT_NAME = None

    @classproperty
    def ROKKITT_FONT_NAME(self):
        if self._ROKKITT_FONT_NAME is None and FontLoader.hasInitialized():
            self._ROKKITT_FONT_NAME = FontLoader.getFamilyName('ROKKITT')
        return self._ROKKITT_FONT_NAME
    
    @classproperty
    def RETHINK_SANS_FONT_NAME(self):
        if self._RETHINK_SANS_FONT_NAME is None and FontLoader.hasInitialized():
            self._RETHINK_SANS_FONT_NAME = FontLoader.getFamilyName('RETHINK_SANS')
        return self._RETHINK_SANS_FONT_NAME

    @classproperty
    def INCLUSIVE_SANS_FONT_NAME(self):
        if self._INCLUSIVE_SANS_FONT_NAME is None and FontLoader.hasInitialized():
            self._INCLUSIVE_SANS_FONT_NAME = FontLoader.getFamilyName('INCLUSIVE_SANS')
        return self._INCLUSIVE_SANS_FONT_NAME

class QMLAppTheme(QObject):
    def __init__(self, parent = None):
        super().__init__(parent)

    @pyqtProperty(str)
    def loginBgMainColor(self): return Theme.LOGIN_BG_MAIN_COLOR

    @pyqtProperty(str)
    def loginBgMainLastColor(self): return Theme.LOGIN_BG_MAIN_LAST_COLOR

    @pyqtProperty(str)
    def bgColor(self): return Theme.BG_COLOR

    @pyqtProperty(str)
    def primaryButtonBgColor(self): return Theme.PRIMARY_BUTTON_BG_COLOR

    @pyqtProperty(str)
    def borderColor(self): return Theme.BORDER_COLOR

    @pyqtProperty(str)
    def darkestTextColor(self): return Theme.DARKEST_TEXT_COLOR

    @pyqtProperty(str)
    def darkTextColor(self): return Theme.DARK_TEXT_COLOR

    @pyqtProperty(str)
    def rokkittFontName(self): return Theme.ROKKITT_FONT_NAME

    @pyqtProperty(str)
    def rethinkSansFontName(self): return Theme.RETHINK_SANS_FONT_NAME

    @pyqtProperty(str)
    def inclusiveSansFontName(self): return Theme.INCLUSIVE_SANS_FONT_NAME
