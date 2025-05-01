import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '~/components/ui/table';
import { Progress } from '~/components/ui/progress';

// Custom wrapper
const SectionWrapper = ({ id, title, source, children }) => (
  <div id={id} className="bg-card shadow-sm rounded-lg">
    <div className="p-3 bg-secondary/30 rounded-t-lg">
      <h2 className="text-base font-semibold text-primary">{title}</h2>
      <p className="text-xs text-muted-foreground">{source}</p>
    </div>
    <div className="p-3">{children}</div>
  </div>
);

const DefaultAnalysis = ({ data }) => {
  if (!data) return <div className="text-center text-muted-foreground text-sm">Нет данных</div>;

  return (
      <div className="space-y-3">
        <div className="grid grid-cols-2 gap-2">
          <div className="text-sm">
            <p className="text-muted-foreground text-xs">Вероятность дефолта</p>
            <p className="font-medium text-primary">{data.probability}%</p>
          </div>
          <div className="text-sm">
            <p className="text-muted-foreground text-xs">Индекс стабильности</p>
            <p className="font-medium text-primary">{data.stabilityIndex?.toFixed(2) || 'Н/Д'}</p>
          </div>
          <div className="text-sm">
            <p className="text-muted-foreground text-xs">Флаг банкротства</p>
            <p className="font-medium text-primary">{data.bankruptcyFlag ? 'Да' : 'Нет'}</p>
          </div>
        </div>
        {data.riskFactors && data.riskFactors.length > 0 ? (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="text-xs text-muted-foreground">Фактор</TableHead>
                <TableHead className="text-xs text-muted-foreground">Влияние</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.riskFactors.map((factor) => (
                <TableRow key={factor.id}>
                  <TableCell className="text-sm text-primary">{factor.factor}</TableCell>
                  <TableCell className="text-sm text-primary">{factor.impact}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        ) : (
          <p className="text-sm text-muted-foreground">Факторы риска отсутствуют</p>
        )}
      </div>
  );
};

export default DefaultAnalysis;