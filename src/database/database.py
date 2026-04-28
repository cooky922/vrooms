from pathlib import Path
from typing import Any, Optional
import sqlite3
import threading


class SQLDatabase:
    _db_path: Optional[Path] = None
    _local = threading.local()

    @classmethod
    def initialize(cls) -> None:
        cls._db_path = Path(__file__).parent / 'data' / 'vrooms_directory.db'
        sql_path = Path(__file__).parent / 'init_db.sql'
        cls._db_path.parent.mkdir(parents=True, exist_ok=True)
        
        conn = sqlite3.connect(cls._db_path)
        try:
            with open(sql_path, 'r', encoding='utf-8') as f:
                conn.executescript(f.read())
            conn.commit()
        except Exception as e:
            conn.close()
            raise e
        conn.close()

    @classmethod
    def _get_connection(cls) -> sqlite3.Connection:
        if cls._db_path is None:
            raise Exception('Database not initialized. Call SQLDatabase.initialize() first.')
        if not hasattr(cls._local, 'conn') or cls._local.conn is None:
            cls._local.conn = sqlite3.connect(cls._db_path, check_same_thread=False)
            cls._local.conn.row_factory = sqlite3.Row
            cls._local.conn.execute('PRAGMA foreign_keys = ON')
        return cls._local.conn

    @classmethod
    def execute(cls, query: str, params: Optional[tuple] = None) -> int:
        conn = cls._get_connection()
        try:
            cursor = conn.execute(query, params or ())
            conn.commit()
            return cursor.rowcount
        except Exception as e:
            conn.rollback()
            raise e

    @classmethod
    def execute_many(cls, query: str, params_seq: list[tuple]) -> int:
        conn = cls._get_connection()
        try:
            cursor = conn.executemany(query, params_seq)
            conn.commit()
            return cursor.rowcount
        except Exception as e:
            conn.rollback()
            raise e

    @classmethod
    def fetch_one(cls, query: str, params: tuple = ()) -> Optional[dict]:
        conn = cls._get_connection()
        cursor = conn.execute(query, params)
        row = cursor.fetchone()
        return dict(row) if row else None

    @classmethod
    def fetch_all(cls, query: str, params: tuple = ()) -> list[dict]:
        conn = cls._get_connection()
        cursor = conn.execute(query, params)
        return [dict(row) for row in cursor.fetchall()]

    @classmethod
    def fetch_scalar(cls, query: str, params: tuple = ()) -> Any:
        row = cls.fetch_one(query, params)
        return next(iter(row.values())) if row else None