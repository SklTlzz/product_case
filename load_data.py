import os
import pandas as pd

from dotenv import load_dotenv
from sqlalchemy import create_engine


load_dotenv()

def split_data(df: pd.DataFrame) -> list[pd.DataFrame]:
    parts_split = len(df) // 5
    parts = []
    
    for i in range(5):
        start_idx = parts_split * i
        end_idx = start_idx + parts_split

        curr_part = df.iloc[start_idx:end_idx] if i < 4 else df.iloc[start_idx:]
        parts.append(curr_part)
        
    return parts


class DatabaseManager:
    def __init__(self, password, user, host, port, db_name):
        db_url = f"postgresql://{user}:{password}@{host}:{port}/{db_name}"        
        self.engine = create_engine(db_url)

    def insert_dataframe(self, table_name: str, df: pd.DataFrame) -> None:
        df.to_sql(name=table_name, con=self.engine, if_exists='append', index=False)


def load_data() -> None:
    DB_PASS = os.getenv("DB_PASS")
    DB_USER = os.getenv("DB_USER")
    DB_HOST = os.getenv("DB_HOST")
    DB_PORT = os.getenv("DB_PORT")
    DB_NAME = os.getenv("DB_NAME")
    tables_list = [
        ("users", "data/thelook_ecommerce.users.csv"),
        ("distribution_centers", "data/thelook_ecommerce.distribution_centers.csv"),
        ("products", "data/thelook_ecommerce.products.csv"),
        ("orders", "data/thelook_ecommerce.orders.csv"),
        ("inventory_items", "data/thelook_ecommerce.inventory_items.csv"),
        ("events", "data/thelook_ecommerce.events.csv"),
        ("order_items", "data/thelook_ecommerce.order_items.csv"),
    ]

    manager = DatabaseManager(DB_PASS, DB_USER, DB_HOST, DB_PORT, DB_NAME)

    for table_name, path in tables_list:
        df = pd.read_csv(path)

        for column in df.columns:
            if column.endswith("_at"):
                df[column] = pd.to_datetime(df[column], format="mixed")

        parts = split_data(df=df)

        for part in parts:
            manager.insert_dataframe(table_name=table_name, df=part)
            print(f"Часть таблицы {table_name} загружена")

        print(f"Таблица {table_name} загружена")

    print("Все загружено")


if __name__ == "__main__":
    load_data()
    