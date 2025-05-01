const mockCompanyData = {
    name: 'Пример ООО',
    general: {
      inn: '1234567890',
      ogrn: '0987654321',
      registrationDate: '2020-01-01',
    },
    defaultAnalysis: {
      probability: 15,
      riskFactors: [
        { id: 1, factor: 'Низкая ликвидность', impact: 'Средний' },
        { id: 2, factor: 'Задолженность по налогам', impact: 'Высокий' },
      ],
    },
    financial: [
      { year: 2023, revenue: 1000000, profit: 200000 },
      { year: 2024, revenue: 1200000, profit: 250000 },
    ],
    arbitration: {
      cases: [
        { id: 1, number: 'А40-12345', status: 'Завершено', date: '2023-05-10', amount: 500000 },
      ],
    },
    procurements: {
      contracts: [
        { id: 1, number: 'ГЗ-2023-001', date: '2023-06-15', amount: 1000000, status: 'Исполнен' },
      ],
    },
    inspections: {
      checks: [
        { id: 1, authority: 'ФНС', date: '2023-07-20', result: 'Нарушений не выявлено' },
        { id: 2, authority: 'Генпрокуратура', date: '2023-08-10', result: 'Выявлены нарушения' },
      ],
    },
  };
  
  export const fetchCompanyData = async (identifier) => {
    try {
      await new Promise((resolve) => setTimeout(resolve, 500));
      if (identifier === 'notfound') {
        throw new Error('Компания не найдена', { status: 404 });
      }
      return { data: mockCompanyData };
    } catch (error) {
      if (error.message === 'Компания не найдена') {
        throw { response: { status: 404 } };
      }
      throw new Error('Не удалось загрузить данные');
    }
  };