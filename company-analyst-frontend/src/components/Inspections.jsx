import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '~/components/ui/table';

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

const Inspections = ({ data }) => {
  if (!data || !data.checks || data.checks.length === 0) {
    return <div className="text-center text-muted-foreground text-sm">Нет данных</div>;
  }

  return (
      <div className="space-y-3">
        <div className="text-sm">
          <p className="text-muted-foreground text-xs">Общая сумма штрафов</p>
          <p className="font-medium text-primary">{data.totalFines?.toLocaleString('ru-RU') || '0'} руб.</p>
        </div>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="text-xs text-muted-foreground">Орган</TableHead>
              <TableHead className="text-xs text-muted-foreground">Дата</TableHead>
              <TableHead className="text-xs text-muted-foreground">Тип</TableHead>
              <TableHead className="text-xs text-muted-foreground">Результат</TableHead>
              <TableHead className="text-xs text-muted-foreground">Нарушение</TableHead>
              <TableHead className="text-xs text-muted-foreground">Штраф</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.checks.map((check) => (
              <TableRow key={check.id}>
                <TableCell className="text-sm text-primary">{check.authority}</TableCell>
                <TableCell className="text-sm text-primary">{check.date}</TableCell>
                <TableCell className="text-sm text-primary">{check.type || 'Н/Д'}</TableCell>
                <TableCell className="text-sm text-primary">{check.result}</TableCell>
                <TableCell className="text-sm text-primary">{check.violation || 'Н/Д'}</TableCell>
                <TableCell className="text-sm text-primary">{check.fine?.toLocaleString('ru-RU') || '0'} руб.</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
  );
};

export default Inspections;