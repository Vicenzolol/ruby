# Changelog

Todas as mudanças relevantes do projeto são documentadas aqui.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [Não lançado]

### Planejado
- Phase 7: API REST `/api/v1`
- Phase 8: Testes com RSpec
- Phase 9: Deploy no Render.com

---

## [0.6.0] — 2026-05-20 — Phase 6: Hotwire/Turbo real-time

### Adicionado
- **importmap-rails instalado**: `config/importmap.rb` criado, `app/javascript/application.js` gerado
- **Turbo + Stimulus instalados**: `turbo:install stimulus:install` — controllers em `app/javascript/controllers/`
- **Turbo Frames** — formulário de nova tarefa abre inline na coluna sem recarregar a página
  - `turbo_frame_tag "new_task_#{status_key}"` em cada coluna do board
  - `tasks/new.html.erb` envolto no mesmo Turbo Frame — clique em "+ Adicionar tarefa" carrega o form inline
- **Turbo Streams (broadcast)** — board atualiza em tempo real para todos os navegadores conectados
  - `turbo_stream_from @project` na view `show.html.erb` inscreve no canal Action Cable do projeto
  - `Task`: `after_create_commit` → `broadcast_append_to` (adiciona card na coluna)
  - `Task`: `after_update_commit` → move card entre colunas se status mudou, ou `broadcast_replace` se só editou
  - `Task`: `after_destroy_commit` → `broadcast_remove_to` (remove card do board)
  - `create.turbo_stream.erb`: template de resposta que insere o card e restaura o link da coluna
- **Turbo Stream (response)** — `TasksController#create` responde com `format.turbo_stream` para requisições Turbo
- **`_task.html.erb`**: adicionado `id="<%= dom_id(task) %>"` para targets dos broadcasts; `data-task-id` e `data-task-status` para o Stimulus
- **SortableJS** adicionado via importmap (`bin/importmap pin sortablejs`)
- **Stimulus `BoardController`** (`app/javascript/controllers/board_controller.js`):
  - Drag-and-drop entre colunas usando SortableJS com `group: "kanban"`
  - `onEnd`: envia `PATCH` com CSRF token para `update_task_status_project_path` atualizando o status
  - Reverte posição visual se o servidor rejeitar
- **`ProjectsController#update_task_status`**: nova action `PATCH /projects/:id/update_task_status` para receber drops
- **`show.html.erb`** atualizado: `data-controller="board"`, `data-board-target="column/taskList"`, `data-status` em cada lista
- **Action Cable**: `async` adapter em development (sem Redis), `redis` em production
- Phase 8: Testes com RSpec
- Phase 9: Deploy no Render.com

---

## [0.5.0] — 2026-05-20 — Phase 5: CRUD completo com Tailwind CSS

### Adicionado
- **Rotas aninhadas (shallow)**: `resources :projects do; resources :tasks, shallow: true; end`
  - Tarefas herdam `project_id` na criação mas usam rotas próprias em edit/update/destroy
- **`ProjectsController`**: 7 actions CRUD com autorização — `Current.user.projects.find` garante que usuário só acessa seus dados
  - `show`: monta `@tasks_by_status` hash (todo/in_progress/done) para o board Kanban
  - `project_params` via `params.expect` (Rails 8 strong parameters)
- **`TasksController`**: 6 actions CRUD com autorização via JOIN — `Task.joins(:project).where(projects: { user_id: ... })`
  - `before_action :set_project` em new/create; `before_action :set_task` em show/edit/update/destroy
- **Views Projects**:
  - `index.html.erb`: grid responsivo de cards com link para novo projeto
  - `show.html.erb`: board Kanban 3 colunas (A Fazer / Em Andamento / Concluído) com contadores e link de nova tarefa por coluna
  - `new.html.erb` / `edit.html.erb`: formulários com partial `_form`
  - `_project.html.erb`: card com cor, nome, contagem de tarefas, links para ver/editar
  - `_form.html.erb`: campos nome, descrição, seletor visual de cores (paleta de 8 dots com radio buttons), exibição de erros
- **Views Tasks**:
  - `new.html.erb` / `edit.html.erb`: formulários com partial `_form`
  - `_task.html.erb`: card com badge de status colorido, título, descrição, links editar/excluir
  - `_form.html.erb`: campos título, descrição, select de status em português
- **Navbar**: adicionado link "Meus Projetos" quando autenticado
- **Autorização básica**: usuário só vê/edita/exclui seus próprios projetos e tarefas (sem gem extra — ActiveRecord puro)

---

## [0.4.0] — 2026-05-20 — Phase 4: Models com ActiveRecord ORM

### Adicionado
- **Model `Project`**: associação `belongs_to :user`, `has_many :tasks, dependent: :destroy`
  - Validações: `name` obrigatório (máx. 100 chars), `color` restrito a paleta de 8 cores hex
  - Constante `COLORS` com paleta predefinida de cores
  - Scope `recent` ordenando por `created_at DESC`
- **Model `Task`**: associação `belongs_to :project`
  - Enum `status` com três estados: `todo (0)`, `in_progress (1)`, `done (2)` — demonstra `enum` do Rails
  - Validações: `title` obrigatório (máx. 200 chars)
  - Scopes: `by_status` (filtra por status), `ordered` (ordena por `position`)
  - Callback `before_create :set_position` — atribui posição sequencial automática por projeto
- **Model `User`**: adicionado `has_many :projects, dependent: :destroy`
- Migrations criadas e executadas — tabelas `projects` e `tasks` no banco
- Factories RSpec geradas: `spec/factories/projects.rb`, `spec/factories/tasks.rb`
- Specs geradas: `spec/models/project_spec.rb`, `spec/models/task_spec.rb`
- README raiz atualizado como hub de documentação com roadmap de aprendizado

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
