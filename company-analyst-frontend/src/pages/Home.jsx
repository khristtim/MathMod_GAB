import SearchBar from '../components/SearchBar';

const Home = () => {
  return (
    <div className="text-center py-8">
      <h1 className="text-4xl font-bold text-primary mb-4">ПСБ Аналитика компаний</h1>
      <p className="text-base text-muted-foreground mb-8 max-w-lg mx-auto">
        Анализируйте компании с легкостью: получайте данные о финансах, арбитражных делах, госзакупках и проверках. Начните с поиска по ИНН, ОГРН или названию.
      </p>
      <div className="max-w-md mx-auto">
        <SearchBar />
      </div>
    </div>
  );
};

export default Home;