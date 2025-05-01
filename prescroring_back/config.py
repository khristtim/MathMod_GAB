import logging
from pathlib import Path

BASE_DIR = Path(__file__).parent
CSV_PATH = BASE_DIR / 'data/features_test.csv'
MODEL_PATH = BASE_DIR / "lgb_model.joblib" 

MIN_QUERY_LENGTH = 5
MAX_SUGGESTIONS = 10

TOP_FEATURES_COUNT = 10

FEATURE_TRANSLATION = {
    'company_age': 'Возраст компании',
    'num_employees': 'Количество сотрудников',
    'tax_debt': 'Налоговая задолженность',
    'paid_taxes': 'Уплаченные налоги',
    'tax_debt_ratio': 'Коэффициент налоговой задолженности',
    'has_state_support': 'Господдержка',
    'has_mass_founder': 'Массовый учредитель',
    'total_assets': 'Общие активы',
    'equity': 'Собственный капитал',
    'current_assets': 'Оборотные активы',
    'inventories': 'Запасы',
    'current_liabilities': 'Краткосрочные обязательства',
    'total_liabilities': 'Общие обязательства',
    'revenue': 'Выручка',
    'net_profit': 'Чистая прибыль',
    'revenue_prev': 'Выручка в прошлом году',
    'current_ratio': 'Текущий коэффициент ликвидности',
    'quick_ratio': 'Быстрая ликвидность',
    'debt_to_equity': 'Коэффициент задолженности к капиталу',
    'debt_to_assets': 'Долг / Активы',
    'roa': 'ROA',
    'roe': 'ROE',
    'gross_margin': 'Валовая маржа',
    'net_margin': 'Чистая маржа',
    'revenue_growth': 'Рост выручки',
    'revenue_cagr_3y': 'Рост выручки 3г',
    'revenue_cagr_5y': 'Рост выручки 5л',
    'roa_avg_3y': 'Средний ROA 3г',
    'roa_avg_5y': 'Средний ROA 5л',
    'roa_std_3y': 'ROA std 3г',
    'roa_std_5y': 'ROA std 5л',
    'debt_to_equity_avg_3y': 'Ср. debt/equity 3г',
    'debt_to_equity_avg_5y': 'Ср. debt/equity 5л',
    'debt_to_equity_trend_3y': 'Тренд debt/equity 3г',
    'debt_to_equity_trend_5y': 'Тренд debt/equity 5л'
}

LOGGING_CONFIG = {
    "level": logging.INFO,
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    "filename": BASE_DIR / "backend.log"
}