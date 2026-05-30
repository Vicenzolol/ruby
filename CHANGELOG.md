# Changelog

Todas as mudanças relevantes do projeto são documentadas aqui.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [Não lançado]

### Planejado
- Phase 9: Deploy no Render.com

---

## [1.0.0] — 2026-05-30 — Phase 8.1: Segurança e Hardening

### Adicionado

#### Rate Limiting — Rack::Attack (`gem "rack-attack"` 6.8.0)
- **`config/initializers/rack_attack.rb`** com 4 throttles:
  - `api/ip`: 60 req/minuto por IP em `/api/v1/*`
  - `logins/ip`: 5 tentativas de login por IP a cada 20 segundos (`POST /session`)
  - `logins/email`: 5 tentativas por e-mail normalizado (lowercase+strip) a cada 20 segundos
  - `passwords/ip`: 5 solicitações de reset de senha por IP por hora (`POST /passwords`)
- Resposta customizada 429 com `Retry-After` header e corpo JSON em português
- Middleware registrado via `config.middleware.use Rack::Attack` no `application.rb`

#### Content Security Policy (CSP)
- **`config/initializers/content_security_policy.rb`** habilitado:
  - `default_src :self` — bloqueia origens não declaradas por padrão
  - `script_src :self` + nonce automático por request (`SecureRandom.base64(16)`)
  - `style_src :self, :unsafe_inline` — necessário para Tailwind CSS + Swagger UI
  - `connect_src :self, ws://localhost:3000, wss://localhost:3000` — ActionCable / Turbo Streams
  - `object_src :none` — bloqueia Flash/Java plugins
  - `frame_ancestors :none` — proteção anti-clickjacking
  - `content_security_policy_nonce_auto = true` — nonce injetado automaticamente em `javascript_include_tag`

#### Análise de Segurança
- **Brakeman 8.0.4**: 0 warnings (10 controllers, 6 models, 18 templates escaneados)
- **bundler-audit** (advisory-db: 1136 advisories): 0 vulnerabilidades
- Testes: 86 exemplos, 0 falhas mantidos após todas as mudanças

---

## [0.9.0] — 2026-05-30 — Phase 8: Testes com RSpec

### Adicionado

#### Infraestrutura de testes
- **Gem `simplecov`** (group :test): cobertura de código gerada em `coverage/index.html`; threshold mínimo configurado em 65% (alcançável sem Chrome)
- **Gem `shoulda-matchers`** (group :dev/test): matchers `belong_to`, `have_many`, `validate_presence_of` etc. integrados ao RSpec/Rails
- **`spec/rails_helper.rb`** atualizado:
  - SimpleCov iniciado antes de qualquer `require` (obrigatório para medir corretamente)
  - Filtros de grupo: Models, Controllers, Views, Helpers
  - `require 'capybara/rails'`
  - Driver `headless_chrome` configurado para system specs
  - `Shoulda::Matchers` integrado ao RSpec + Rails

#### Model specs (`spec/models/`)
- **`user_spec.rb`**: validações email (presença, formato, unicidade, normalização), senha (mínimo 8 chars), geração automática de `api_token`, unicidade do token, `authenticate_by_token`, `regenerate_api_token!`, associations (`has_many sessions/projects` com `dependent: :destroy`)
- **`project_spec.rb`**: validações `name` (presença, máximo 100 chars), `color` (inclusão na paleta ou em branco), scope `.recent` (ordenação decrescente), constante `COLORS` (8 hexadecimais), `dependent: :destroy` das tasks, `belongs_to :user`
- **`task_spec.rb`**: validações `title` (presença, máximo 200 chars), enum `status` (todo/in_progress/done + predicados), scopes `.by_status` e `.ordered`, callback `set_position` (sequência por projeto, isolamento entre projetos), `belongs_to :project`

#### Request specs web (`spec/requests/`)
- **`projects_spec.rb`** (reescrito do stub): redirect sem auth (GET /, /new, /:id), acesso autenticado via POST /session, create 201/422, delete com contagem
- **`tasks_spec.rb`** (reescrito do stub): redirect sem auth, create 201/422, delete com contagem

#### System specs (`spec/system/`)
- **`kanban_spec.rb`**: fluxo completo com Capybara/headless Chrome — cadastro, login/logout, criação de projeto, visualização do board, criação de tarefa; requer `google-chrome-stable` no WSL

#### Seeds
- **`db/seeds.rb`** reescrito com Faker: 2 usuários fixos (`admin@`, `dev@`), 3 projetos cada com Faker::App.name, 5–10 tasks por projeto com statuses variados; idempotente via `find_or_initialize_by`

#### Resultados
- **86 exemplos, 0 falhas** (`spec/models/` + `spec/requests/`)
- Cobertura: **67.38%** (219/325 linhas) — supera o threshold de 65%

---

## [0.8.0] — 2026-05-31 — Phase 7.1 e 7.2: Swagger, Jbuilder e Paginação

### Adicionado

#### Phase 7.1 — Documentação Swagger (rswag)
- **Gems**: `rswag-api`, `rswag-ui` (grupo principal); `rswag-specs` (dev/test)
- **Initializers**: `rswag_api.rb` (`openapi_root`) e `rswag_ui.rb` (`openapi_endpoint`) gerados e corrigidos para API rswag 2.17
- **Rotas**: `mount Rswag::Ui::Engine => '/api-docs'` e `mount Rswag::Api::Engine => '/api-docs'`
- **`spec/swagger_helper.rb`**: schema OpenAPI 3.0.1 completo com componentes `Project`, `ProjectWithTasks`, `Task`, `PaginationMeta`, `Error` e esquema de segurança `bearerAuth`
- **`spec/requests/api/v1/projects_spec.rb`**: specs rswag para todos os endpoints de Projects (13 casos: 200, 201, 204, 401, 404, 422)
- **`spec/requests/api/v1/tasks_spec.rb`**: specs rswag para todos os endpoints de Tasks (13 casos)
- **`swagger/v1/swagger.yaml`**: gerado via `RAILS_ENV=test bundle exec rails rswag` — 26 exemplos, 0 falhas
- Swagger UI disponível em `/api-docs`

#### Phase 7.2 — Serialização Jbuilder e Paginação pagy
- **Gem pagy 43.x**: `config/initializers/pagy.rb` com `require "pagy/toolbox/paginators/method"`, limite padrão 20, máximo 100
- **`Api::V1::BaseController`**: inclui `Pagy::Method` (v43+), `ActionView::Rendering`/`Layouts`, `prepend_view_path`, `rescue_from Pagy::RangeError`; `json_error` normaliza arrays
- **`Api::V1::ProjectsController`**: `index` paginado (`?page=&per_page=`), `render :show` em create/update
- **`Api::V1::TasksController`**: `index` paginado com filtro `?status=`, `render :show` em create/update
- **Views Jbuilder**:
  - `app/views/api/v1/projects/_project.json.jbuilder`
  - `app/views/api/v1/projects/index.json.jbuilder` — `{ data: [...], meta: { current_page, total_pages, total_count, per_page } }`
  - `app/views/api/v1/projects/show.json.jbuilder` — projeto + tasks
  - `app/views/api/v1/tasks/_task.json.jbuilder`
  - `app/views/api/v1/tasks/index.json.jbuilder` — paginado
  - `app/views/api/v1/tasks/show.json.jbuilder`
- **`app/models/task.rb`**: inclui `ActionView::RecordIdentifier` para `dom_id` (Turbo broadcasts)
- **`api.http`**: adicionados exemplos de paginação com `?page=` e `?per_page=`

#### Infraestrutura de Testes (RSpec/FactoryBot)
- **`rspec:install`**: `.rspec`, `spec/spec_helper.rb`, `spec/rails_helper.rb` com `FactoryBot::Syntax::Methods`
- **Factories**: `spec/factories/users.rb` (sequência de email), `spec/factories/projects.rb` (Faker + COLORS), `spec/factories/tasks.rb` (Faker + status)

---

## [0.7.1] — 2026-05-30 — Phase 4.1: Integridade do Banco de Dados

### Adicionado
- **Migration `20260530000001`** `AddDatabaseConstraintsAndIndexes`: garante integridade em nível de banco, não apenas no model
- **`null: false`** em `tasks.status` — preenche NULLs existentes com `0` (todo) via `change_column_null` com valor padrão antes de aplicar a constraint
- **`null: false`** em `tasks.title` — impossível criar tarefa sem título mesmo contornando as validações do model
- **`null: false`** em `projects.name` — idem para projetos
- **`default: 0`** em `tasks.status` — novas tasks iniciam com status `todo` automaticamente no banco
- **Índice `index_tasks_on_status`** — evita full table scan ao filtrar tarefas por coluna Kanban
- **Índice `index_tasks_on_position`** — ordena tarefas eficientemente pelo scope `:ordered`
- **Índice composto `index_tasks_on_project_id_and_status`** — cobre a query mais frequente da API e do board (`WHERE project_id = X AND status = Y`)
- **`schema.rb`** atualizado: versão `2026_05_30_000001`, constraints e índices refletidos com precisão

---

## [0.7.0] — 2026-05-20 — Phase 7: API REST `/api/v1`

### Adicionado
- **Migration**: coluna `api_token` (string, unique) na tabela `users`
- **`User` model**: `before_create :generate_api_token` (gera token único `SecureRandom.urlsafe_base64(32)`), `self.authenticate_by_token`, `regenerate_api_token!`
- **`Api::V1::BaseController`** (`ActionController::API`): autenticao por `Authorization: Bearer <token>` — retorna 401 com mensagem em português se ausente ou inválido
- **`Api::V1::ProjectsController`**: CRUD completo (index, show, create, update, destroy) — autorização por `current_user.projects`
  - `show` inclui array de tarefas (`include_tasks: true`)
- **`Api::V1::TasksController`**: index (com filtro `?status=todo|in_progress|done`), show, create, update, destroy — autorização via JOIN
- **`Api::V1::UsersController#me`**: `GET /api/v1/me` retorna dados do usuário + `api_token`
- **Rotas**: namespace `api > v1` com resources aninhados (`projects > tasks`) e rota `me`
- **`api.http`**: arquivo REST Client com todos os endpoints documentados e exemplos de requisições (incluindo casos de erro 401)

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
