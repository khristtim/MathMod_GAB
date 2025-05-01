import { Card, CardHeader, CardTitle, CardContent } from './ui/card';
import { format } from 'date-fns';

const GeneralInfo = ({ data }) => {
  if (!data) return <div className="text-center text-gray-500">Нет данных</div>;

  return (
    <Card className="mb-4 border-none shadow-none">
      <CardHeader>
        <CardTitle>Общая информация</CardTitle>
      </CardHeader>
      <CardContent>
        <p><strong>ИНН:</strong> {data.inn}</p>
        <p><strong>ОГРН:</strong> {data.ogrn}</p>
        <p><strong>Дата регистрации:</strong> {format(new Date(data.registrationDate), 'dd.MM.yyyy')}</p>
      </CardContent>
    </Card>
  );
};

export default GeneralInfo;