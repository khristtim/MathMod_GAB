import pandas as pd
import logging
from typing import List
from pathlib import Path
from exceptions import DataNotFoundError, InvalidInputError

logger = logging.getLogger(__name__)

class DataHandler:
    """Класс для работы с данными компаний из DataFrame."""
    
    def __init__(self, csv_path: Path):
        """Инициализация с загрузкой DataFrame."""
        try:
            self.df = pd.read_csv(csv_path)
            self.df = self._preprocess_dataframe()
            logger.info("DataFrame loaded and preprocessed successfully")
            logger.debug(f"DataFrame columns: {self.df.columns.tolist()}")
            logger.debug(f"Sample INN values: {self.df['inn'].head().tolist()}")
        except Exception as e:
            logger.error(f"Failed to load DataFrame: {e}")
            raise DataNotFoundError(f"Failed to load DataFrame: {e}")
    
    def _preprocess_dataframe(self) -> pd.DataFrame:
        """Предобработка DataFrame."""
        df = self.df.copy()
        # Проверка наличия столбца 'inn'
        if 'inn' not in df.columns:
            logger.error("Column 'inn' not found in DataFrame")
            raise DataNotFoundError("Column 'inn' not found in DataFrame")
        
        # Преобразование 'inn' в строку с удалением десятичных частей, если это float
        df['inn'] = df['inn'].astype(str).str.replace(r'\.0$', '', regex=True)
        logger.debug(f"INN column type after conversion: {df['inn'].dtype}")
        
        # Предобработка других столбцов
        df['has_state_support'] = df['has_state_support'].apply(
            lambda x: 1 if x in [1, '1', True, 't'] else 0
        )
        df['has_mass_founder'] = df['has_mass_founder'].apply(
            lambda x: 1 if x in ['t', True] else 0
        )
        df = df.fillna(0)
        return df
    
    def get_company_features(self, inn: str, features: List[str]) -> pd.DataFrame:
        """Получение признаков компании по ИНН."""
        company_data = self.df[self.df['inn'] == inn][features]
        if company_data.empty:
            logger.warning(f"Company with INN {inn} not found")
            raise DataNotFoundError(f"Company with INN {inn} not found")
        if company_data.shape[1] != len(features):
            logger.error(f"Invalid features for INN {inn}")
            raise DataNotFoundError(f"Invalid features for INN {inn}")
        return company_data
    
    def search_companies(self, query: str, max_suggestions: int) -> List[str]:
        """Поиск ИНН компаний по частичному совпадению."""
        if len(query) < 5:
            logger.warning(f"Search query '{query}' is too short")
            raise InvalidInputError("Query must be at least 5 characters long")
        if not query.isdigit():
            logger.warning(f"Invalid query '{query}': must contain only digits")
            raise InvalidInputError("Query must contain only digits")
        
        logger.debug(f"Searching for INN starting with: {query}")
        suggestions = self.df[self.df['inn'].str.startswith(query)]['inn'].unique().tolist()
        logger.debug(f"Found suggestions: {suggestions}")
        return suggestions[:max_suggestions]