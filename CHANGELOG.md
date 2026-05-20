# Changelog

Todas as mudanças relevantes do projeto são documentadas aqui.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [Não lançado]

### Planejado
- Phase 4: Models Project e Task com ActiveRecord ORM
- Phase 5: CRUD completo com Tailwind
- Phase 6: Hotwire/Turbo real-time (Turbo Frames + Streams)
- Phase 7: API REST `/api/v1`
- Phase 8: Testes com RSpec
- Phase 9: Deploy no Render.com

---

## [0.3.0] — 2026-05-20 — Phase 3: Autenticação

### Adicionado
- Sistema de autenticação nativo do Rails 8 (`rails generate authentication`)
- Models: `User`, `Session`, `Current`
- `Authentication` concern no `ApplicationController` (protege todas as rotas por padrão)
- `RegistrationsController` — cadastro de novos usuários (`/registration/new`)
- `SessionsController` — login e logout (`/session`)
- `PasswordsController` — redefinição de senha por e-mail
- Views de login e cadastro em português com Tailwind CSS
- Navbar responsiva com: logo, email do usuário logado, botão Sair / links Entrar e Criar conta
- Flash messages globais no layout (verde para sucesso, vermelho para erros)
- Validações no `User`: formato de e-mail, unicidade e senha mínimo 8 caracteres
- `root "sessions#new"` — página inicial é o login

### Alterado
- `application.html.erb` — adicionados navbar, flash messages e `<main>` com padding Tailwind
- `sessions/new.html.erb` — traduzido para português ("Entrar", "Esqueci minha senha")
- `config/routes.rb` — adicionados `resource :registration` e `root`

---

## [0.2.0] — 2026-05-20 — Phase 2: Projeto Rails + banco de dados

### Adicionado
- Projeto Rails 8.1 criado (`rails new kanbanflow --database=postgresql --css=tailwind`)
- Configuração do PostgreSQL (`config/database.yml`)
- Bancos de dados criados: `kanbanflow_development` e `kanbanflow_test`
- Gems adicionadas: `rspec-rails`, `factory_bot_rails`, `faker`, `capybara`
- `mcp.json` com configuração dos MCPs para VS Code (Context7, Playwright, GitHub)
- Título da aplicação alterado para "Aprendendo e Fazendo Kanban"

### Corrigido
- Ruby atualizado de 3.3.0 para 3.4.9 (compatibilidade com Rails 8.1 / `actionview 8.1.3`)
- Removido `.git` interno do `kanbanflow/` (criado automaticamente pelo `rails new`)
- `git config core.fileMode false` para evitar falsos positivos de modificação no Windows/WSL

---

## [0.1.0] — 2026-05-20 — Phase 1: Setup do ambiente

### Adicionado
- WSL2 (Ubuntu 24.04) instalado e configurado
- rbenv + ruby-build instalados
- Ruby 3.3.0 instalado (depois migrado para 3.4.9)
- PostgreSQL instalado no WSL2
- Role PostgreSQL `vicen` criado como superusuário
- Node.js 24 instalado via nvm
- VS Code com extensões: Remote-WSL, Ruby, Rails, Solargraph, RuboCop, REST Client, GitLens
- Smithery CLI instalado (`npm install -g @smithery/cli`)
- Repositório GitHub criado e configurado
