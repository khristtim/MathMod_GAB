from fastapi import FastAPI, Depends
from config import CSV_PATH, MODEL_PATH, LOGGING_CONFIG
from data_handler import DataHandler
from model_service import ModelService
from routes import router
from fastapi.middleware.cors import CORSMiddleware
import logging

# Настройка логирования
logging.basicConfig(**LOGGING_CONFIG)
logger = logging.getLogger(__name__)

# Инициализация FastAPI
app = FastAPI(title="Company Default Prediction API")

# 1) CORS middleware: разрешаем запросы с dev-сервера React
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],  # ваш фронтенд
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 2) Регистрируем ваш API-router
app.include_router(router, prefix="")

# Инициализация сервисов
data_handler = DataHandler(CSV_PATH)
model_service = ModelService(MODEL_PATH)

# Зависимости
def get_data_handler():
    return data_handler

def get_model_service():
    return model_service

# Подключение роутов
app.include_router(
    router,
    dependencies=[Depends(get_data_handler), Depends(get_model_service)]
)

# Запуск сервера
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)