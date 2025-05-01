FROM python:3.13-slim

# Установка рабочей директории
WORKDIR /app

# Копирование requirements.txt и установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода приложения
COPY config.py .
COPY data_handler.py .
COPY model_service.py .
COPY routes.py .
COPY main.py .
COPY exceptions.py .

# Копирование данных и модели
COPY data.csv .
COPY lgb_model.joblib .  

# Установка переменной окружения для порта
ENV PORT=8000

# Команда для запуска приложения
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]