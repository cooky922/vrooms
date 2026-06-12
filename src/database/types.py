from dataclasses import dataclass
from enum import Enum
from typing import Optional

@dataclass
class Filter:
    options: dict

    @staticmethod
    def By(options: dict) -> 'Filter':
        return Filter(options)

@dataclass
class Sorted:
    column: str
    ascending: bool = True

    @staticmethod
    def By(column: str, ascending: bool = True) -> 'Sorted':
        return Sorted(column, ascending)

@dataclass
class Paged:
    size: int
    index: Optional[int] = None

    @staticmethod
    def Specific(index: int, size: int) -> 'Paged':
        return Paged(size=size, index=index)

    @staticmethod
    def Stream(size: int) -> 'Paged':
        return Paged(size=size, index=None)

class SearchMatchType(Enum):
    CONTAINS = 0
    EXACTLY = 1
    STARTS_WITH = 2
    ENDS_WITH = 3

@dataclass
class Search:
    text: str
    field: Optional[str] = None
    match_type: SearchMatchType = SearchMatchType.CONTAINS