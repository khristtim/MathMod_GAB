from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Union
from data_handler import DataHandler
from model_service import ModelService
from config import MIN_QUERY_LENGTH, MAX_SUGGESTIONS, TOP_FEATURES_COUNT, CSV_PATH, MODEL_PATH
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

# Модели ответа
class PredictionResponse(BaseModel):
    predicted_class: int
    top_features: List[dict]

class SearchResponse(BaseModel):
    suggestions: List[str]

# Эндпоинт для предсказания
@router.get("/predict/{inn}", response_model=PredictionResponse)
async def predict(inn: str):
    try:
        logger.info(f"Received predict request for INN: {inn}")
        # Валидация INN
        if not inn.isdigit():
            logger.warning(f"Invalid INN '{inn}': must contain only digits")
            raise HTTPException(status_code=400, detail="INN must contain only digits")
        if len(inn) not in [10, 12]:
            logger.warning(f"Invalid INN '{inn}': length must be 10 or 12 digits")
            raise HTTPException(status_code=400, detail="INN length must be 10 or 12 digits")
        
        # Создаем экземпляры DataHandler и ModelService
        data_handler = DataHandler(CSV_PATH)
        model_service = ModelService(MODEL_PATH)
        
        # Получение признаков
        X = data_handler.get_company_features(inn, model_service.features)
        # Предсказание
        predicted_class, _ = model_service.predict(X)
        # SHAP-анализ с значениями признаков
        top_features = model_service.get_top_features(X, TOP_FEATURES_COUNT)
        return {"predicted_class": predicted_class, "top_features": top_features}
    except DataNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except ModelError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        logger.error(f"Unexpected error for INN {inn}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

# Эндпоинт для поиска
@router.get("/search/{query}", response_model=SearchResponse)
async def search(query: str):
    try:
        logger.info(f"Received search request with query: {query}")
        # Валидация query
        if not query.isdigit():
            logger.warning(f"Invalid query '{query}': must contain only digits")
            raise HTTPException(status_code=400, detail="Query must contain only digits")
        # Создаем экземпляр DataHandler
        data_handler = DataHandler(CSV_PATH)
        suggestions = data_handler.search_companies(query, MAX_SUGGESTIONS)
        return {"suggestions": suggestions}
    except InvalidInputError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Unexpected error for query {query}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")