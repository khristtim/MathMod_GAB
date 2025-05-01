import { Outlet, NavLink } from 'react-router-dom';

const Layout = () => {
  return (
    <div className="flex flex-col min-h-screen bg-background">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 bg-psb-gradient text-primary-foreground shadow-md z-10">
        <div className="max-w-4xl mx-auto px-4 py-4 flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-primary-foreground">ПСБ Аналитика</h1>
            <p className="text-xs font-medium text-accent">
              Надежный анализ компаний для вашего бизнеса
            </p>
          </div>
          <nav className="flex gap-6">
            <NavLink
              to="/"
              className={({ isActive }) =>
                `text-sm font-medium transition-colors hover:text-accent ${
                  isActive ? 'text-primary-foreground underline' : 'text-muted-foreground'
                }`
              }
            >
              Главная
            </NavLink>
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-grow pt-24 pb-12 max-w-4xl mx-auto px-4 w-full">
        <Outlet />
      </main>

      {/* Footer */}
      <footer className="bg-psb-footer-gray text-primary-foreground py-6 border-t border-border">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <p className="text-sm font-medium text-primary-foreground">© 2025 Промсвязьбанк. Все права защищены.</p>
          <div className="flex justify-center gap-6 mt-3">
            <a href="#" className="text-sm text-primary-foreground hover:text-accent transition-colors">Политика конфиденциальности</a>
            <a href="#" className="text-sm text-primary-foreground hover:text-accent transition-colors">Условия использования</a>
            <a href="#" className="text-sm text-primary-foreground hover:text-accent transition-colors">Контакты</a>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Layout;