import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
  } from '~/components/ui/table';
  
  import { Info } from 'lucide-react';
  import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
  } from '~/components/ui/tooltip';
  
  const MetricCard = ({ title, value, unit = '', tooltip }) => (
    <div className="p-4 rounded-2xl bg-muted/40 shadow-sm hover:shadow-md transition">
      <div className="flex items-center gap-1 mb-1">
        <p className="text-xs text-muted-foreground">{title}</p>
        {tooltip && (
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Info className="w-3.5 h-3.5 text-muted-foreground hover:text-primary cursor-pointer" />
              </TooltipTrigger>
              <TooltipContent
                side="top"
                sideOffset={8}
                className="bg-background border border-muted rounded-md shadow-lg px-3 py-2 z-50 max-w-[300px]"
                >
                <p className="text-xs text-muted-foreground">{tooltip}</p>
            </TooltipContent>

            </Tooltip>
          </TooltipProvider>
        )}
      </div>
      <p className="text-lg font-semibold text-primary">{value ?? 'Н/Д'}{unit}</p>
    </div>
  );
  
  // Wrapper for section
  const SectionWrapper = ({ id, title, source, children }) => (
    <div id={id} className="bg-card shadow-sm rounded-lg">
      <div className="p-4 bg-secondary/30 rounded-t-lg">
        <h2 className="text-base font-semibold text-primary">{title}</h2>
        <p className="text-xs text-muted-foreground">{source}</p>
      </div>
      <div className="p-4">{children}</div>
    </div>
  );
  
  const FinancialData = ({ data }) => {
    if (!data || data.length === 0) {
      return <div className="text-center text-muted-foreground text-sm">Нет данных</div>;
    }
  
    const latest = data[0];
  
    return (
        <div className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <MetricCard
              title="Рентабельность продаж"
              value={latest.profitabilityRatio?.toFixed(2)}
              unit="%"
              tooltip="Чистая прибыль / Выручка — итоговая доходность бизнеса"
            />
            <MetricCard
              title="Чистая прибыль"
              value={latest.netProfit?.toLocaleString('ru-RU')}
              unit=" руб."
              tooltip="Финансовый результат после уплаты налогов"
            />
            <MetricCard
              title="Коэффициент ликвидности"
              value={latest.currentRatio?.toFixed(2)}
              tooltip="Текущие активы / Текущие обязательства — способность погашать долги"
            />
            <MetricCard
              title="Общий долг"
              value={latest.liabilities?.toLocaleString('ru-RU')}
              unit=" руб."
              tooltip="Совокупные обязательства компании (долгосрочные и краткосрочные)"
            />
            <MetricCard
              title="Активы"
              value={latest.assets?.toLocaleString('ru-RU')}
              unit=" руб."
              tooltip="Все ресурсы компании (деньги, имущество, задолженности дебиторов и пр.)"
            />
            <MetricCard
              title="Выручка"
              value={latest.revenue?.toLocaleString('ru-RU')}
              unit=" руб."
              tooltip="Общая сумма доходов от основной деятельности"
            />
            <MetricCard
              title="Прибыль до налогообложения"
              value={latest.profit?.toLocaleString('ru-RU')}
              unit=" руб."
              tooltip="Разница между выручкой и расходами до налогов"
            />
          </div>
  
          <div>
            <h3 className="text-sm font-medium text-muted-foreground mb-2">История по годам</h3>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="text-xs text-muted-foreground">Год</TableHead>
                  <TableHead className="text-xs text-muted-foreground">Выручка</TableHead>
                  <TableHead className="text-xs text-muted-foreground">Прибыль</TableHead>
                  <TableHead className="text-xs text-muted-foreground">Чистая прибыль</TableHead>
                  <TableHead className="text-xs text-muted-foreground">Активы</TableHead>
                  <TableHead className="text-xs text-muted-foreground">Обязательства</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data.map((item, index) => (
                  <TableRow key={index}>
                    <TableCell className="text-sm text-primary">{item.year}</TableCell>
                    <TableCell className="text-sm text-primary">
                      {item.revenue?.toLocaleString('ru-RU')} руб.
                    </TableCell>
                    <TableCell className="text-sm text-primary">
                      {item.profit?.toLocaleString('ru-RU')} руб.
                    </TableCell>
                    <TableCell className="text-sm text-primary">
                      {item.netProfit?.toLocaleString('ru-RU') || 'Н/Д'} руб.
                    </TableCell>
                    <TableCell className="text-sm text-primary">
                      {item.assets?.toLocaleString('ru-RU') || 'Н/Д'} руб.
                    </TableCell>
                    <TableCell className="text-sm text-primary">
                      {item.liabilities?.toLocaleString('ru-RU') || 'Н/Д'} руб.
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </div>
    );
  };
  
  export default FinancialData;
  