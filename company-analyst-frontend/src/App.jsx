import React, { useState } from "react";
import {
  Card, CardHeader, CardTitle, CardContent,
} from "./components/ui/card";
import { Input } from "./components/ui/input";
import { Button } from "./components/ui/button";
import { Badge } from "./components/ui/badge";
import { Label } from "./components/ui/label";
import { Separator } from "./components/ui/separator";

export default function App() {
  const [inn, setInn] = useState("");
  const [prediction, setPrediction] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const companyName = inn ? `Компания ИНН ${inn}` : null;

  async function getPrediction() {
    if (inn.length < 5) return;
    setLoading(true);
    setError("");
    setPrediction(null);
    try {
      const res = await fetch(`http://localhost:8000/predict/${encodeURIComponent(inn)}`);
      const payload = await res.json();
      if (!res.ok) throw new Error(payload.detail || `Ошибка ${res.status}`);
      setPrediction(payload);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  const positiveFactors = prediction
    ? prediction.top_features
        .filter(f => f.shap_value < 0)
        .sort((a,b) => Math.abs(b.shap_value) - Math.abs(a.shap_value))
    : [];
  const negativeFactors = prediction
    ? prediction.top_features
        .filter(f => f.shap_value > 0)
        .sort((a,b) => Math.abs(b.shap_value) - Math.abs(a.shap_value))
    : [];

  return (
    <div className="min-h-screen bg-gray-100 p-8 flex flex-col items-center">
      {/* Заголовок страницы */}
      <div className="w-full max-w-4xl text-center mb-8">
        <h1 className="text-4xl font-extrabold text-gray-900">Анализ риска дефолта компании</h1>
        <p className="mt-2 text-gray-600">
          Введите ИНН компании, чтобы оценить вероятность квази-дефолта на основе 
          машинного скоринга и SHAP-анализа.
        </p>
      </div>

      {/* Методика расчёта */}
      <Card className="w-full max-w-4xl mb-8">
        <CardHeader>
          <CardTitle className="text-2xl">Как это работает</CardTitle>
        </CardHeader>
        <CardContent className="text-gray-700 space-y-4">
          <p>
            Мы обучили градиентный бустинг на исторических данных компаний. 
            Для каждого ИНН модель выдаёт вероятность дефолта, а SHAP-анализ 
            показывает, какие финансовые показатели наиболее влияют на решение:
          </p>
          <ul className="list-disc list-inside space-y-1">
            <li><strong>SHAP больше 0</strong> — увеличивает риск дефолта;</li>
            <li><strong>SHAP меньше 0</strong> — снижает риск дефолта.</li>
          </ul>
          <p className="text-sm text-gray-500">
            Методика основана на принципах fair-credit-scoring и интерпретируемости модели.
          </p>
        </CardContent>
      </Card>

      <Card className="w-full max-w-4xl mb-8 shadow-md border border-gray-200 rounded-xl">
  <CardHeader className="border-b border-gray-100 pb-4">
    <CardTitle className="text-2xl font-bold text-gray-900 text-center">
      🔍 Проверка компании по ИНН
    </CardTitle>
  </CardHeader>

  <CardContent className="p-6 space-y-6">
    <div className="flex flex-col md:flex-row md:items-end md:space-x-4 space-y-4 md:space-y-0">
      <div className="flex-1">
        <Label
          htmlFor="inn"
          className="block text-sm font-medium text-gray-700 mb-1"
        >
          Введите ИНН компании
        </Label>
        <Input
          id="inn"
          type="text"
          inputMode="numeric"
          pattern="[0-9]*"
          value={inn}
          onChange={e => setInn(e.target.value.replace(/\D/g, ""))}
          placeholder="Например: 7728191040"
          className="block w-full rounded-md border border-gray-300 shadow-sm focus:border-blue-500 focus:ring-1 focus:ring-blue-500 text-base px-4 py-2 transition"
        />
      </div>
      <Button
        onClick={getPrediction}
        disabled={inn.length < 5 || loading}
        className="px-6 py-2.5 rounded-md bg-blue-600 text-white font-semibold hover:bg-blue-700 transition disabled:opacity-50"
      >
        {loading ? "⏳ Загрузка..." : "📊 Узнать риск"}
      </Button>
    </div>

    {error && (
      <div className="text-sm text-red-700 bg-red-50 border border-red-200 px-4 py-2 rounded-md">
        {error}
      </div>
    )}
  </CardContent>
</Card>




      {prediction && (
        <Card className="w-full max-w-4xl mb-8 shadow-md">
          <CardHeader className="pb-4 border-b border-gray-200">
            {/* Главный заголовок — имя компании */}
            {companyName && (
              <div className="w-full text-center text-3xl font-extrabold text-gray-900 mb-2">
                {companyName}
              </div>
            )}

            {/* Результат скоринга */}
            <div className="flex items-center justify-center space-x-3">
              {prediction.predicted_class === 1 ? (
                <Badge className="bg-red-100 text-red-800 border border-red-200 px-4 py-1 rounded-full text-sm font-medium">
                  Высокий риск
                </Badge>
              ) : (
                <Badge className="bg-green-100 text-green-800 border border-green-200 px-4 py-1 rounded-full text-sm font-medium">
                  Низкий риск
                </Badge>
              )}
            </div>
          </CardHeader>

          <CardContent className="space-y-6">
  {/* Общий пояснительный текст */}
  <p className="text-gray-600">
    Ниже показаны ключевые факторы, которые <strong className="text-green-700">снижают риск</strong> дефолта и те, что <strong className="text-red-700">повышают риск</strong>. 
    Чем больше абсолютное SHAP-значение, тем сильнее влияние.
  </p>

  <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
    {/* Блок «Снижают риск» */}
    <div className="bg-green-100 p-6 rounded-lg border border-green-200">
      <h3 className="text-xl font-semibold text-green-900 mb-2">
        🌟 Факторы, снижающие риск
      </h3>
      <Separator className="mb-4" />
      {positiveFactors.length ? positiveFactors.map(f => (
        <div key={f.feature} className="mb-4 p-4 bg-white rounded-md shadow-sm hover:shadow-md transition">
          <div className="text-2xl font-bold text-green-800">
            {f.feature_value.toFixed(2)}
          </div>
          <div className="mt-1 text-sm font-medium text-green-700">
            {f.feature}
          </div>
          <div className="text-xs text-gray-500 mt-1">
            SHAP вклад: <span className="font-mono">{f.shap_value.toFixed(3)}</span>
          </div>
        </div>
      )) : (
        <div className="text-sm text-green-700">Нет заметных факторов, снижающих риск</div>
      )}
    </div>

    {/* Блок «Повышают риск» */}
    <div className="bg-red-100 p-6 rounded-lg border border-red-200">
      <h3 className="text-xl font-semibold text-red-900 mb-2">
        ⚠️ Факторы, повышающие риск
      </h3>
      <Separator className="mb-4" />
      {negativeFactors.length ? negativeFactors.map(f => (
        <div key={f.feature} className="mb-4 p-4 bg-white rounded-md shadow-sm hover:shadow-md transition">
          <div className="text-2xl font-bold text-red-800">
            {f.feature_value.toFixed(2)}
          </div>
          <div className="mt-1 text-sm font-medium text-red-700">
            {f.feature}
          </div>
          <div className="text-xs text-gray-500 mt-1">
            SHAP вклад: <span className="font-mono">{f.shap_value.toFixed(3)}</span>
          </div>
        </div>
      )) : (
        <div className="text-sm text-red-700">Нет заметных факторов, повышающих риск</div>
      )}
    </div>
  </div>

  {/* Финальное пояснение */}
  <p className="text-gray-500 text-sm">
    * SHAP-значение показывает, насколько признак изменил прогноз модели относительно среднего:  
    отрицательное → снизил риск, положительное → повысил риск.  
    Эти факторы помогут вам понять, где сосредоточить внимание при улучшении финансового состояния компании.
  </p>
</CardContent>

        </Card>
      )}
    </div>
  );
}
