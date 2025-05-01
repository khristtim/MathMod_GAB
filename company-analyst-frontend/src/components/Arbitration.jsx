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

const Arbitration = ({ data }) => {
  if (!data || !data.cases || data.cases.length === 0) {
    return <div className="text-center text-muted-foreground text-sm">Нет данных</div>;
  }

  return (
      <div className="space-y-3">
        <div className="text-sm">
          <p className="text-muted-foreground text-xs">Общая сумма исков</p>
          <p className="font-medium text-primary">{data.totalClaims?.toLocaleString('ru-RU') || '0'} руб.</p>
        </div>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="text-xs text-muted-foreground">Номер дела</TableHead>
              <TableHead className="text-xs text-muted-foreground">Статус</TableHead>
              <TableHead className="text-xs text-muted-foreground">Дата</TableHead>
              <TableHead className="text-xs text-muted-foreground">Сумма</TableHead>
              <TableHead className="text-xs text-muted-foreground">Тип</TableHead>
              <TableHead className="text-xs text-muted-foreground">Роль</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.cases.map((caseItem) => (
              <TableRow key={caseItem.id}>
                <TableCell className="text-sm text-primary">{caseItem.number}</TableCell>
                <TableCell className="text-sm text-primary">{caseItem.status}</TableCell>
                <TableCell className="text-sm text-primary">{caseItem.date}</TableCell>
                <TableCell className="text-sm text-primary">{caseItem.amount.toLocaleString('ru-RU')} руб.</TableCell>
                <TableCell className="text-sm text-primary">{caseItem.type || 'Н/Д'}</TableCell>
                <TableCell className="text-sm text-primary">{caseItem.role || 'Н/Д'}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
  );
};

export default Arbitration;