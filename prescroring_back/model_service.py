import joblib
import numpy as np
import pandas as pd
import shap
import logging
from typing import List, Dict, Tuple
from pathlib import Path
from exceptions import ModelError
from config import FEATURE_TRANSLATION

logger = logging.getLogger(__name__)

class ModelService:
    """Класс для работы с моделью и SHAP-анализом."""
    
    def __init__(self, model_path: Path):
        """Инициализация с загрузкой модели и SHAP-эксплейнера."""
        try:
            model_data = joblib.load(model_path)
            self.model = model_data['model']
            self.features = model_data['features']
            self.threshold = model_data['threshold']
            self.explainer = shap.TreeExplainer(self.model)
            logger.info("Model and SHAP explainer initialized")
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise ModelError(f"Failed to load model: {e}")
    
    def predict(self, X: pd.DataFrame) -> Tuple[int, float]:
        """Предсказание класса и вероятности."""
        try:
            y_pred_proba = self.model.predict(X)[0]
            y_pred = int(y_pred_proba > self.threshold)
            logger.info(f"Prediction: class {y_pred}, probability {y_pred_proba:.4f}")
            return y_pred, y_pred_proba
        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            raise ModelError(f"Prediction failed: {e}")
    
    def get_top_features(self, X: pd.DataFrame, top_n: int) -> List[Dict[str, any]]:
        """Top-N признаков по SHAP для одного примера X (с сохранением знака)."""
        try:
            # 1) получаем массив(ы) shap-значений
            shap_values_all = self.explainer.shap_values(X)
            # для классификации TreeExplainer возвращает список [shap_class0, shap_class1]
            shap_for_class1 = shap_values_all[1] if isinstance(shap_values_all, list) else shap_values_all
            # 2) берём именно ту строку, которую предскаваем (0-й пример)
            instance_shap = shap_for_class1[0]        # shape = (n_features,)
            instance_vals = X.iloc[0].values          # shape = (n_features,)

            # 3) составляем DataFrame с сохранением знака
            df = pd.DataFrame({
                'feature': self.features,
                'shap_value': instance_shap,         # теперь со знаком
                'abs_shap': np.abs(instance_shap),   # модуль для сортировки
                'feature_value': instance_vals
            })

            # 4) сортируем по абсолютному вкладу и берём top_n
            top = df.sort_values('abs_shap', ascending=False).head(top_n)

            # 5) форматируем в нужный вид
            return [
                {
                    "feature": FEATURE_TRANSLATION.get(row['feature'], row['feature']),
                    "shap_value": float(row['shap_value']),       # со знаком!
                    "feature_value": row['feature_value']
                }
                for _, row in top.iterrows()
            ]
        except Exception as e:
            logger.error(f"SHAP analysis failed: {e}")
            raise ModelError(f"SHAP analysis failed: {e}")
