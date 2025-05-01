import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Input } from './ui/input';
import { Button } from './ui/button';

const SearchBar = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const navigate = useNavigate();

  const handleSearch = () => {
    if (searchTerm.trim()) {
      navigate(`/company/${searchTerm}`);
    }
  };

  return (
    <div className="flex gap-2">
      <Input
        placeholder="Введите ИНН, ОГРН или название компании"
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        className="border-border bg-background text-foreground rounded-md shadow-sm focus:ring-primary focus:ring-2"
      />
      <Button
        onClick={handleSearch}
        className="bg-psb-gradient text-primary-foreground hover:bg-accent hover:scale-105 rounded-md shadow-sm transition-all duration-200"
      >
        Поиск
      </Button>
    </div>
  );
};

export default SearchBar;