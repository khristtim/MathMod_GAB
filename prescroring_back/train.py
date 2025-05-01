import pandas as pd
import numpy as np
import lightgbm as lgb
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import f1_score, roc_auc_score, precision_recall_curve
import shap
import joblib
import uuid
import matplotlib.pyplot as plt

# Функция для вычисления коэффициента Джини
def gini_score(y_true, y_pred_proba):
    auc = roc_auc_score(y_true, y_pred_proba)
    return 2 * auc - 1

# Чтение данных
csv_path = 'data/features.csv'  # Укажите путь к вашему CSV
df = pd.read_csv(csv_path)

# Предобработка данных
df['has_state_support'] = df['has_state_support'].apply(lambda x: 1 if x in [1, '1', True, 't'] else 0)
df['has_mass_founder'] = df['has_mass_founder'].apply(lambda x: 1 if x in ['t', True] else 0)
df = df.fillna(0)  # Заполнение пропусков нулями

# Подготовка данных
X = df.drop(['inn', 'target'], axis=1)
y = df['target'].astype(int)

# Разделение на обучающую и тестовую выборки
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

# Параметры LightGBM
lgb_params = {
    'objective': 'binary',
    'metric': 'binary_logloss',
    'boosting_type': 'gbdt',
    'num_leaves': 31,
    'learning_rate': 0.05,
    'feature_fraction': 0.8,
    'bagging_fraction': 0.8,
    'bagging_freq': 5,
    'random_state': 42,
    'scale_pos_weight': (y_train == 0).sum() / (y_train == 1).sum()  # Учет несбалансированности
}

# Кросс-валидация для оценки модели
skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
f1_scores = []
gini_scores = []
for train_idx, val_idx in skf.split(X, y):
    X_train_cv, X_val_cv = X.iloc[train_idx], X.iloc[val_idx]
    y_train_cv, y_val_cv = y.iloc[train_idx], y.iloc[val_idx]
    train_data_cv = lgb.Dataset(X_train_cv, label=y_train_cv)
    val_data_cv = lgb.Dataset(X_val_cv, label=y_val_cv, reference=train_data_cv)
    model_cv = lgb.train(lgb_params, train_data_cv, num_boost_round=1000, valid_sets=[val_data_cv],
                         callbacks=[lgb.early_stopping(stopping_rounds=50, verbose=False)])
    y_pred_proba_cv = model_cv.predict(X_val_cv)
    y_pred_cv = (y_pred_proba_cv > 0.5).astype(int)
    f1_scores.append(f1_score(y_val_cv, y_pred_cv))
    gini_scores.append(gini_score(y_val_cv, y_pred_proba_cv))
print(f"Mean CV F1: {np.mean(f1_scores):.4f} ± {np.std(f1_scores):.4f}")
print(f"Mean CV Gini: {np.mean(gini_scores):.4f} ± {np.std(gini_scores):.4f}")

# Обучение начальной модели
train_data = lgb.Dataset(X_train, label=y_train)
test_data = lgb.Dataset(X_test, label=y_test, reference=train_data)
model = lgb.train(lgb_params, train_data, num_boost_round=1000, valid_sets=[test_data],
                  callbacks=[lgb.early_stopping(stopping_rounds=50, verbose=False)])

# Оптимизация порога для F1-меры
y_pred_proba = model.predict(X_test)
precisions, recalls, thresholds = precision_recall_curve(y_test, y_pred_proba)
f1_scores = 2 * (precisions * recalls) / (precisions + recalls + 1e-10)
optimal_threshold = thresholds[np.argmax(f1_scores)]
y_pred = (y_pred_proba > optimal_threshold).astype(int)
f1_initial = f1_score(y_test, y_pred)
gini_initial = gini_score(y_test, y_pred_proba)
print(f"Initial model - F1: {f1_initial:.4f}, Gini: {gini_initial:.4f}, Optimal threshold: {optimal_threshold}")

# SHAP-анализ для интерпретации и отбора признаков
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_train)
shap_values_positive = shap_values[1] if isinstance(shap_values, list) else shap_values

# Важность признаков
shap_importance = np.abs(shap_values_positive).mean(axis=0)
shap_importance_df = pd.DataFrame({'feature': X.columns, 'importance': shap_importance})
shap_importance_df = shap_importance_df.sort_values(by='importance', ascending=False)

# Сохранение SHAP-графика
plt.figure(figsize=(10, 8))
shap.summary_plot(shap_values_positive, X_train, plot_type="bar", show=False)
plt.savefig('shap_importance.png')
plt.close()

# Отбор признаков (удаление нижних 20% по SHAP-важности)
threshold = shap_importance_df['importance'].quantile(0.2)
selected_features = shap_importance_df[shap_importance_df['importance'] > threshold]['feature'].tolist()

# Обучение модели на отобранных признаках
X_train_selected = X_train[selected_features]
X_test_selected = X_test[selected_features]
train_data_selected = lgb.Dataset(X_train_selected, label=y_train)
test_data_selected = lgb.Dataset(X_test_selected, label=y_test, reference=train_data_selected)
model_selected = lgb.train(lgb_params, train_data_selected, num_boost_round=1000, valid_sets=[test_data_selected],
                           callbacks=[lgb.early_stopping(stopping_rounds=50, verbose=False)])

# Оценка модели с отобранными признаками
y_pred_proba_selected = model_selected.predict(X_test_selected)
y_pred_selected = (y_pred_proba_selected > optimal_threshold).astype(int)
f1_selected = f1_score(y_test, y_pred_selected)
gini_selected = gini_score(y_test, y_pred_proba_selected)
print(f"Selected features model - F1: {f1_selected:.4f}, Gini: {gini_selected:.4f}")

# Выбор лучшей модели
if gini_selected > gini_initial:
    final_model = model_selected
    final_features = selected_features
    print("Using model with selected features")
else:
    final_model = model
    final_features = X.columns.tolist()
    print("Using initial model")

# Сохранение финальной модели
model_filename = f"lgb_model.joblib"
joblib.dump({'model': final_model, 'features': final_features, 'threshold': optimal_threshold}, model_filename)
print(f"Model saved as {model_filename}")

# Сохранение списка отобранных признаков
with open('selected_features.txt', 'w') as f:
    f.write('\n'.join(final_features))

from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, precision_score, recall_score
import seaborn as sns
import datetime

# Сохранение confusion matrix для модели с отобранными признаками
conf_matrix_selected = confusion_matrix(y_test, y_pred_selected)
print(conf_matrix_selected)
plt.figure(figsize=(6, 5))
sns.heatmap(conf_matrix_selected, annot=True, fmt='d', cmap='Blues', cbar=False)
plt.title('Confusion Matrix (Selected Features Model)')
plt.xlabel('Predicted Label')
plt.ylabel('True Label')
conf_matrix_path = 'confusion_matrix_selected.png'
plt.savefig(conf_matrix_path)
plt.close()

# Генерация Markdown-отчета
now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
with open("model_report.md", "w") as f:
    f.write(f"# 📊 Отчет о модели скоринга\n")
    f.write(f"_Сформировано: {now}_\n\n")
    
    f.write("## 🔍 Метрики модели ДО SHAP-отбора признаков\n")
    f.write(f"- **F1-score**: {f1_initial:.4f}\n")
    f.write(f"- **Gini**: {gini_initial:.4f}\n")

    f.write("## 🧬 Метрики модели ПОСЛЕ SHAP-отбора признаков\n")
    f.write(f"- **F1-score**: {f1_selected:.4f}\n")
    f.write(f"- **Gini**: {gini_selected:.4f}\n")
    f.write(f"- **Количество признаков**: {len(selected_features)} из {X.shape[1]}\n\n")

    f.write("## ✅ Финальное решение\n")
    if gini_selected > gini_initial:
        f.write("- **Выбрана модель с SHAP-фильтрацией признаков**\n")
    else:
        f.write("- **Выбрана исходная модель со всеми признаками**\n")
    f.write(f"- **Модель сохранена как**: `{model_filename}`\n\n")

    f.write("## 🖼️ Матрица ошибок (Confusion Matrix)\n")
    f.write(f"![Confusion Matrix]({conf_matrix_path})\n")
    
    # Сохранение SHAP-важности признаков
    shap_importance_path = 'shap_importance.png'
    plt.savefig(shap_importance_path)
    plt.close()
    f.write("## 📊 Важность признаков по SHAP\n")
    f.write(f"![SHAP Feature Importance]({shap_importance_path})\n")

    # Добавление метрик из финального обучения
    f.write("## 📈 Финальные метрики обученной модели\n")
    f.write(f"- **F1-score (final)**: {f1_selected:.4f}\n")
    f.write(f"- **Gini (final)**: {gini_selected:.4f}\n")

print("Model report generated successfully.")