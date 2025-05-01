# errors.py

class DataNotFoundError(Exception):
    """Ресурс не найден."""
    def __init__(self, resource: str, identifier: str):
        # resource — что ищем, identifier — по какому ключу
        self.resource = resource
        self.identifier = identifier
        message = f"{resource} с идентификатором {identifier} не найден."
        super().__init__(message)


class InvalidInputError(Exception):
    """Входные данные некорректны."""
    def __init__(self, field: str, reason: str = None):
        # field — имя поля, reason — причина невалидности
        self.field = field
        self.reason = reason or "недопустимое значение"
        message = f"Поле '{field}' содержит недопустимое значение: {self.reason}."
        super().__init__(message)


class ModelError(Exception):
    """Ошибка внутри модели (предсказание/обучение)."""
    def __init__(self, model_name: str, detail: str = None):
        self.model_name = model_name
        self.detail = detail or "неизвестная ошибка модели"
        message = f"Модель '{model_name}' завершилась с ошибкой: {self.detail}."
        super().__init__(message)
