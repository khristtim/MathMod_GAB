import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { fetchCompanyData } from '../services/api';
import GeneralInfo from '../components/GeneralInfo';
import DefaultAnalysis from '../components/DefaultAnalysis';
import FinancialData from '../components/FinancialData';
import Arbitration from '../components/Arbitration';
import Procurements from '../components/Procurements';
import Inspections from '../components/Inspections';
import { Button } from '~/components/ui/button';
import { Loader2, AlertCircle } from 'lucide-react';

// Custom wrapper component
const SectionWrapper = ({ id, title, source, children }) => (
  <div id={id} className="bg-card shadow-sm rounded-lg">
    <div className="p-3 bg-secondary/30 rounded-t-lg">
      <h2 className="text-base font-semibold text-primary">{title}</h2>
      <p className="text-xs text-muted-foreground">{source}</p>
    </div>
    <div className="p-3">{children}</div>
  </div>
);

const CompanyPage = () => {
  const { identifier } = useParams();
  const navigate = useNavigate();
  const [companyData, setCompanyData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const getData = async () => {
      setLoading(true);
      try {
        const response = await fetchCompanyData(identifier);
        setCompanyData(response.data);
        setLoading(false);
      } catch (err) {
        if (err.response && err.response.status === 404) {
          setError('Компания не найдена');
        } else {
          setError('Не удалось загрузить данные');
        }
        setLoading(false);
      }
    };
    getData();
  }, [identifier]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[300px] bg-background">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
        <p className="mt-2 text-sm text-primary">Загрузка данных компании...</p>
      </div>
    );
  }

  if (error || !companyData) {
    return (
      <div className="p-3 text-center bg-card shadow-sm rounded-lg">
        <div className="flex flex-col items-center">
          <AlertCircle className="h-6 w-6 text-accent mb-1" />
          <p className="text-sm text-accent mb-1">
            {error || 'Компания не найдена'}. Попробуйте изменить запрос или{' '}
            <a href="/" className="text-primary hover:text-accent transition-colors underline">
              вернуться на главную
            </a>.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="py-3">
      {/* Header */}
      <div className="flex items-center justify-between mb-3">
        <div>
          <h1 className="text-xl font-bold text-primary">{companyData.name}</h1>
          <p className="text-xs text-muted-foreground">
            ИНН: {companyData.general?.inn || 'Н/Д'} | ОГРН: {companyData.general?.ogrn || 'Н/Д'}
          </p>
        </div>
        <Button
          onClick={() => navigate(-1)}
          className="bg-psb-gradient text-primary-foreground hover:bg-accent hover:scale-105 rounded-md shadow-sm transition-all duration-200 text-sm h-8 px-3"
        >
          Назад
        </Button>
      </div>

      {/* Main Content */}
      <div className="grid grid-cols-1 lg:grid-cols-[200px_1fr] gap-3">
        {/* Sidebar Navigation */}
        <div className="lg:sticky lg:top-20 lg:self-start">
          <div className="bg-card shadow-sm rounded-lg">
            <div className="p-3">
              <nav className="flex flex-col gap-1">
                {[
                  { id: 'general', label: 'Общая информация' },
                  { id: 'financial', label: 'Финансы' },
                  { id: 'arbitration', label: 'Арбитраж' },
                  { id: 'procurements', label: 'Закупки' },
                  { id: 'inspections', label: 'Проверки' },
                ].map((item) => (
                  <a
                    key={item.id}
                    href={`#${item.id}`}
                    className="text-sm font-medium text-primary hover:text-accent hover:bg-accent/10 transition-colors py-1 px-2 rounded-md"
                  >
                    {item.label}
                  </a>
                ))}
              </nav>
            </div>
          </div>
        </div>

        {/* Content Sections */}
        <div className="space-y-3">
          {/* Summary Section */}
          <SectionWrapper
            id="general"
            title="Общая информация"
            source="Данные из ЕГРЮЛ (ФНС РФ) о регистрации, статусе и руководстве компании."
          >
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mb-2">
              <div className="text-sm">
                <p className="text-muted-foreground text-xs">Статус</p>
                <p className="font-medium text-primary">{companyData.general?.status || 'Н/Д'}</p>
              </div>
              <div className="text-sm">
                <p className="text-muted-foreground text-xs">Выручка</p>
                <p className="font-medium text-primary">{companyData.financial?.[0]?.revenue?.toLocaleString('ru-RU') || 'Н/Д'} руб.</p>
              </div>
              <div className="text-sm">
                <p className="text-muted-foreground text-xs">Индекс стабильности</p>
                <p className="font-medium text-primary">{companyData.defaultAnalysis?.stabilityIndex?.toFixed(2) || 'Н/Д'}</p>
              </div>
              <div className="text-sm">
                <p className="text-muted-foreground text-xs">Штрафы</p>
                <p className="font-medium text-primary">{companyData.inspections?.totalFines?.toLocaleString('ru-RU') || '0'} руб.</p>
              </div>
            </div>
            {/* <GeneralInfo data={companyData.general} /> */}
            <DefaultAnalysis data={companyData.defaultAnalysis} />
          </SectionWrapper>

          {/* Financial Data */}
          <SectionWrapper
            id="financial"
            title="Финансы"
            source="Финансовая отчетность из Росстат и ФНС, включая выручку, прибыль и активы."
          >
            <FinancialData data={companyData.financial} />
          </SectionWrapper>

          {/* Arbitration */}
          <SectionWrapper
            id="arbitration"
            title="Арбитраж"
            source="Сведения о судебных делах из баз ФССП и арбитражных судов РФ."
          >
            <Arbitration data={companyData.arbitration} />
          </SectionWrapper>

          {/* Procurements */}
          <SectionWrapper
            id="procurements"
            title="Закупки"
            source="Данные о госзакупках с портала zakupki.gov.ru."
          >
            <Procurements data={companyData.procurements} />
          </SectionWrapper>

          {/* Inspections */}
          <SectionWrapper
            id="inspections"
            title="Проверки"
            source="Информация о проверках от Роспотребнадзора, Роструда и других ведомств."
          >
            <Inspections data={companyData.inspections} />
          </SectionWrapper>
        </div>
      </div>
    </div>
  );
};

export default CompanyPage;