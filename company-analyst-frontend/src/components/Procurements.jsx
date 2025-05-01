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

const Procurements = ({ data }) => {
  if (!data || !data.contracts || data.contracts.length === 0) {
    return <div className="text-center text-muted-foreground text-sm">Нет данных</div>;
  }

  return (
      <div className="space-y-3">
        <div className="text-sm">
          <p className="text-muted-foreground text-xs">Общая сумма контрактов</p>
          <p className="font-medium text-primary">{data.totalValue?.toLocaleString('ru-RU') || '0'} руб.</p>
        </div>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="text-xs text-muted-foreground">Номер контракта</TableHead>
              <TableHead className="text-xs text-muted-foreground">Дата</TableHead>
              <TableHead className="text-xs text-muted-foreground">Сумма</TableHead>
              <TableHead className="text-xs text-muted-foreground">Заказчик</TableHead>
              <TableHead className="text-xs text-muted-foreground">Тип тендера</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.contracts.map((contract) => (
              <TableRow key={contract.id}>
                <TableCell className="text-sm text-primary">{contract.number}</TableCell>
                <TableCell className="text-sm text-primary">{contract.date}</TableCell>
                <TableCell className="text-sm text-primary">{contract.amount.toLocaleString('ru-RU')} руб.</TableCell>
                <TableCell className="text-sm text-primary">{contract.customer || 'Н/Д'}</TableCell>
                <TableCell className="text-sm text-primary">{contract.tenderType || 'Н/Д'}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
  );
};

export default Procurements;