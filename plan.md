# Plano: KanbanFlow — Ruby on Rails 8 completo para vaga

## TL;DR
Construir "KanbanFlow", um gerenciador de tarefas Kanban full-featured em Rails 8, cobrindo auth, CRUD, Hotwire/Turbo real-time, API REST, testes e deploy no Render. Ambiente: WSL2 (a instalar) + Ruby 3.3 + Rails 8 + PostgreSQL + Tailwind + Stimulus.

---

## Decisões
- **Projeto**: KanbanFlow - Gerenciador Kanban com tempo real
- **Ambiente**: WSL2 (Ubuntu 22.04) - a instalar do zero
- **Auth**: Rails 8 `generate authentication` (sem Devise)
- **Assets**: tailwindcss-rails gem + importmap
- **Testes**: RSpec + FactoryBot + Capybara + Faker
- **Deploy**: Render.com (PostgreSQL + Web Service)
- **Experiência usuário**: Conhece PHP/Python/JS - pular basicões de programação
- **Fora do escopo**: Docker, Devise, JWT, Redis, Action Mailer real

---

## Database Schema
- users: id, email_address, password_digest, created_at, updated_at
- sessions: id, user_id, ip_address, user_agent, created_at
- projects: id, user_id, name, description, color, created_at, updated_at
- tasks: id, project_id, title, description, status(enum:todo/in_progress/done), position(int), created_at, updated_at
- labels: id, name, color (has_and_belongs_to_many tasks - para mostrar ActiveRecord avançado)

---

## Phase 0: Ruby para quem já programa (1-2h estudo)
1. Ler comparativo Ruby vs PHP/JS: sintaxe, blocos, procs, lambdas, symbols
2. OOP Ruby: classes, herança, módulos, mixins (vs PHP traits)
3. Gems e Bundler (vs npm/Composer)
4. IRB para experimentar (vs browser console)
- Recursos: ruby-lang.org/pt, railstutorial.org

## Phase 1: Setup do Ambiente — WSL2 + Ruby + Rails
1. Instalar WSL2 no Windows (Ubuntu 22.04)
   - `wsl --install -d Ubuntu-22.04` no PowerShell como admin
   - Reiniciar, configurar usuário Linux
2. Dentro do WSL2:
   - Instalar dependências: `sudo apt update && sudo apt install -y git curl libssl-dev...`
   - Instalar rbenv + ruby-build
   - `rbenv install 3.3.0 && rbenv global 3.3.0`
   - `gem install rails`
   - Verificar: `ruby -v`, `rails -v`
3. Instalar PostgreSQL no WSL2
   - `sudo apt install postgresql postgresql-contrib libpq-dev`
   - Configurar usuário postgres
4. Instalar Node.js (via nvm) para assets
5. VS Code com extensão Remote-WSL para abrir projeto do WSL no editor
6. Instalar extensões VS Code: Ruby, Rails, Solargraph, RuboCop, REST Client, GitLens
7. Instalar MCPs: Context7, Playwright, GitHub MCP via Smithery
   - `npm install -g @smithery/cli`
   - `smithery mcp add context7`
   - `smithery mcp add playwright`

## Phase 2: Criar o Projeto Rails 8
1. `rails new kanbanflow --database=postgresql --css=tailwind` dentro do WSL
2. Configurar `config/database.yml` com credenciais PostgreSQL
3. `rails db:create`
4. Commit inicial ao GitHub (MCP GitHub para criar repo)
5. Explorar estrutura MVC: app/models, controllers, views, config/routes.rb
6. Instalar gems extras no Gemfile: rspec-rails, factory_bot_rails, faker, capybara

## Phase 3: Autenticação (Rails 8 native)
1. `rails generate authentication`
   - Cria: User, Session, PasswordResetToken models
   - Controllers: sessions, passwords, password_reset_tokens
   - Views: login, signup, password reset
2. `rails db:migrate`
3. Adicionar signup ao routes.rb (`resource :registration`)
4. Criar RegistrationsController
5. Proteger rotas com `before_action :require_authentication`
6. Adicionar `current_user` helper nas views
7. Navbar com links de login/logout

## Phase 4: Models & ActiveRecord ORM
1. Gerar model Project: `rails g model Project user:references name:string description:text color:string`
2. Gerar model Task: `rails g model Task project:references title:string description:text status:integer position:integer`
3. Adicionar validações nos models (presence, length, format)
4. Adicionar associations: User has_many projects, Project has_many tasks, belongs_to user
5. Adicionar enum para status: `enum status: { todo: 0, in_progress: 1, done: 2 }`
6. Adicionar scopes: `scope :by_status, -> (s) { where(status: s) }`
7. Callback `before_create` para definir position
8. `rails db:migrate`

## Phase 4.1: Integridade do Banco de Dados
1. Criar migration adicionando `null: false` nas colunas obrigatórias: `tasks.title`, `tasks.status`, `projects.name`
2. Adicionar índice em `tasks.status` para filtros por coluna Kanban sem full table scan
3. Adicionar índice composto `[project_id, status]` em tasks — query mais frequente da API
4. Adicionar índice em `tasks.position` para ordenações eficientes no board
5. Verificar que `schema.rb` reflete todos os constraints — o banco de dados deve garantir integridade, não apenas o model
6. `bundle exec rails db:migrate` e confirmar `schema.rb` atualizado

## Phase 5: CRUD Completo — Projects e Tasks
1. `rails g controller Projects index show new create edit update destroy`
2. Configurar rotas: `resources :projects do; resources :tasks; end`
3. Views com Tailwind: index (cards), show (board Kanban), new/edit (forms)
4. Tasks CRUD aninhado (nested resources): tasks pertencem a projects
5. Redirect e flash messages após actions
6. Autorização básica: usuário só vê seus próprios projetos
7. Partials para reutilização: `_project.html.erb`, `_task.html.erb`

## Phase 6: Hotwire/Turbo Real-time (a cereja do bolo)
1. Turbo Drive já ativo por padrão (SPA-like navigation)
2. Turbo Frames: form de nova task abre inline sem reload
   - `<%= turbo_frame_tag "new_task" %>`
3. Turbo Streams: quando status da task muda, atualiza coluna Kanban
   - `task.rb`: `after_update_commit { broadcast_update_to "project_#{project_id}" }`
   - View: `<%= turbo_stream_from "project_#{@project.id}" %>`
4. Stimulus Controller: drag-and-drop das tarefas entre colunas
   - `app/javascript/controllers/sortable_controller.js` (usando SortableJS)
   - Enviar nova posição/status via `fetch` ao Rails
5. Demonstrar as 5 ações Turbo Streams: append, prepend, update, remove, replace

## Phase 7: API REST (/api/v1)
1. Criar namespace em routes.rb: `namespace :api do; namespace :v1 do`
2. `app/controllers/api/v1/base_controller.rb` herdando ActionController::API
3. Token authentication para API: gerar api_token no User model
4. `app/controllers/api/v1/projects_controller.rb` - CRUD JSON
5. `app/controllers/api/v1/tasks_controller.rb` - CRUD JSON com filtro por status
6. `respond_to` blocks nos controllers principais (HTML + JSON)
7. Testar com REST Client (VS Code) ou arquivo `.http`

## Phase 7.1: Documentação Swagger (rswag) ✨ Bônus
> Depende da Phase 7 (API) e da Phase 8 (RSpec) — idealmente feita após as duas.
> A gem `rswag` gera um Swagger/OpenAPI 3.0 interativo a partir dos próprios testes RSpec.

1. Adicionar gems ao Gemfile:
   ```ruby
   gem "rswag-api"   # serve o JSON do spec em /api-docs
   gem "rswag-ui"    # interface Swagger UI em /api-docs (HTML)
   group :development, :test do
     gem "rswag-specs"  # DSL RSpec para escrever os specs que geram o YAML
   end
   ```
2. `bundle install`
3. `rails generate rswag:install`
   - Cria: `spec/swagger_helper.rb`, `config/initializers/rswag_api.rb`, `config/initializers/rswag_ui.rb`
   - Monta rota `/api-docs` automaticamente
4. Escrever specs Swagger em `spec/requests/api/v1/` usando DSL do rswag:
   ```ruby
   # spec/requests/api/v1/projects_spec.rb
   path '/api/v1/projects' do
     get 'Lista projetos' do
       tags 'Projetos'
       security [bearer: []]
       response '200', 'sucesso' do
         schema type: :array, items: { '$ref' => '#/components/schemas/Project' }
         run_test!
       end
       response '401', 'não autorizado' do
         run_test!
       end
     end
   end
   ```
5. Definir schemas OpenAPI em `spec/swagger_helper.rb`:
   - `Project`: id, name, description, color, tasks_count, created_at
   - `Task`: id, project_id, title, description, status (enum), position, created_at
   - `securitySchemes`: bearerAuth (HTTP Bearer)
6. `bundle exec rake rswag:specs:swaggerize` → gera `swagger/v1/swagger.yaml`
7. Acessar `http://localhost:3000/api-docs` → Swagger UI interativo
   - Botão "Authorize" para inserir o Bearer token
   - Testar todos os endpoints diretamente no browser

### Resultado esperado
- `/api-docs` → Swagger UI completo e interativo
- `/api-docs/v1/swagger.yaml` → spec OpenAPI 3.0 para integrar com outras ferramentas
- Documentação sempre sincronizada com os testes (não fica desatualizada)

## Phase 7.2: Serialização e Paginação da API
1. Extrair serialização dos controllers para Jbuilder views em `app/views/api/v1/`
   - `projects/index.json.jbuilder`, `projects/show.json.jbuilder`, `projects/_project.json.jbuilder`
   - Princípio da Responsabilidade Única: controller orquestra, view serializa
2. Adicionar gem `pagy` para paginação nos endpoints de listagem
   - `GET /api/v1/projects?page=1&per_page=20`
   - `GET /api/v1/projects/:id/tasks?page=1&status=todo`
   - Response envelope: `{ data: [...], meta: { current_page:, total_pages:, total_count: } }`
3. Padronizar envelope de erro em todos os endpoints: `{ error: "mensagem" }` com status HTTP correto
4. Atualizar `api.http` com exemplos de paginação e todos os cenários de erro

## Phase 8: Testes com RSpec
1. Confirmar instalação do RSpec e configurar `spec/rails_helper.rb` com FactoryBot e Faker
2. Garantir que as **factories** em `spec/factories/` refletem o estado atual dos models com dados realistas via Faker
3. **Model specs** — testes reais para cada model:
   - `user_spec.rb`: validação de email (formato, unicidade), comprimento mínimo de password, geração de `api_token` no `before_create`, `authenticate_by_token`
   - `project_spec.rb`: presença e comprimento máximo de `name`, `color` só aceita valores válidos, scope `recent`, `has_many :tasks dependent: :destroy`
   - `task_spec.rb`: presença de `title`, enum `status` (todo/in_progress/done), scope `by_status`, scope `ordered`, callback `set_position` incrementa corretamente
4. **Request specs da API** — fluxos de sucesso e falha:
   - `spec/requests/api/v1/projects_spec.rb`: index (200), show com tasks (200), create (201), update (200), destroy (204), sem token (401), token inválido (401), projeto de outro usuário (404)
   - `spec/requests/api/v1/tasks_spec.rb`: index com `?status=` (200), create (201), update de status (200), destroy (204), acesso a task de outro usuário (404)
5. **Seeds de desenvolvimento**: popular `db/seeds.rb` com Faker — 2 usuários, 3 projetos cada, 5–10 tasks por projeto em statuses variados
6. **System specs (Capybara)**: fluxo completo — cadastro → login → criar projeto → criar task → mover entre colunas → logout
7. Rodar `bundle exec rspec --format documentation` — todos os testes passando
8. Adicionar `simplecov` no `group :test` para medir cobertura — objetivo mínimo 80%

## Phase 8.1: Segurança e Hardening
1. **Hash do API token**: substituir armazenamento em texto puro por digest — salvar `BCrypt::Password.create(token)`, entregar o token raw apenas na criação/regeneração
2. **Rate limiting**: adicionar gem `rack-attack`
   - `config/initializers/rack_attack.rb`: throttle por IP (60 req/min na API, 5 tentativas de login por 20s)
   - Retornar `429 Too Many Requests` com header `Retry-After` ao exceder o limite
3. **Revisão de CSP**: ajustar `config/initializers/content_security_policy.rb` para bloquear inline scripts desnecessários em produção
4. Rodar `bin/brakeman --no-pager` e `bin/bundler-audit` — zero warnings antes de qualquer deploy
5. Confirmar que nenhuma credencial está hardcoded — tudo via `ENV[]` ou Rails credentials

## Phase 9: Deploy no Render.com
1. Garantir `gem 'pg'` no Gemfile
2. Criar `bin/render-build.sh`:
   - bundle install, assets:precompile, db:migrate
3. `chmod +x bin/render-build.sh`
4. Commit e push para GitHub
5. No Render.com:
   - Criar PostgreSQL → copiar Internal Database URL
   - Criar Web Service → conectar repo
   - Build Command: `./bin/render-build.sh`
   - Start Command: `bin/rails server -b 0.0.0.0`
   - Env vars: DATABASE_URL, RAILS_MASTER_KEY, RAILS_ENV=production
6. Deploy! Verificar logs

---

## Ferramentas AI / MCPs
- **Context7 MCP**: docs Rails 8 atualizadas, sem alucinações
- **Playwright MCP**: testes E2E automatizados com IA
- **GitHub MCP**: criar repo, PRs, issues
- **VS Code Copilot Agent**: scaffolding, geração de testes, refactoring

## Arquivos-chave no projeto final
- `config/routes.rb` — todas as rotas (resources aninhados + API namespace)
- `app/models/user.rb` — auth + associations
- `app/models/task.rb` — enum, scopes, Turbo broadcasts
- `app/controllers/tasks_controller.rb` — CRUD + respond_to
- `app/controllers/api/v1/tasks_controller.rb` — REST API
- `app/views/api/v1/projects/_project.json.jbuilder` — serialização JSON da API
- `app/javascript/controllers/sortable_controller.js` — Stimulus drag-drop
- `app/views/projects/show.html.erb` — Board Kanban com Turbo Streams
- `config/initializers/rack_attack.rb` — rate limiting por IP
- `spec/requests/api/v1/projects_spec.rb` — request specs da API com auth
- `spec/system/tasks_spec.rb` — Capybara E2E
- `db/seeds.rb` — dados de exemplo para desenvolvimento
- `bin/render-build.sh` — deploy script

## Verificação
1. `rails server` local sem erros
2. `bundle exec rspec --format documentation` — todos os testes passando, cobertura ≥ 80%
3. `GET /api/v1/projects?page=1` retorna dados + metadados de paginação
4. `bin/brakeman --no-pager` e `bin/bundler-audit` sem warnings
5. `bundle exec rails db:seed` cria dados de exemplo sem erros
6. Criar task e ver atualização real-time no board sem reload
7. App funcionando em URL pública no Render com PostgreSQL em produção


Plano: KanbanFlow — Ruby on Rails 8 do zero ao deploy
TL;DR: Vamos construir o "KanbanFlow", um gerenciador de tarefas Kanban com updates em tempo real. Ele cobre absolutamente tudo da sua lista. O ambiente será WSL2 no Windows (muito melhor que Ruby nativo), com Ruby 3.3, Rails 8, PostgreSQL e Tailwind. Todo o fluxo de desenvolvimento será turbinado com MCPs e GitHub Copilot.

## Ferramentas de IA que vamos usar
| Ferramenta | Para quê | Instalação |
| --- | --- | --- |
| Context7 MCP | Docs Rails 8 atualizadas direto no Copilot (sem alucinações) | smithery mcp add context7 |
| Playwright MCP | Rodar testes E2E automatizados com IA | smithery mcp add playwright |
| GitHub MCP | Criar repo, PRs e issues sem sair do VS Code | smithery mcp add github |
| Copilot Agent | Scaffolding, gerar testes, refactoring, explicar código | Já instalado |
| REST Client (VSCode) | Testar a API REST direto no editor | extensão humao.rest-client |

## Phase 0 — Ruby para quem já programa (1–2h)
- Ler comparativo Ruby vs PHP/JS: blocos, symbols, nil vs null, do...end
- Entender OOP Ruby: classes, módulos como mixins (igual PHP traits)
- Gems + Bundler = npm + package.json / Composer + composer.json
- Brincar no IRB (console interativo) como se fosse o console do browser

## Phase 1 — Setup do Ambiente (WSL2 do zero)
- Instalar WSL2 no PowerShell como admin: wsl --install -d Ubuntu-22.04 → reiniciar
- Dentro do Ubuntu WSL2:
  - Dependências do sistema (libssl-dev, libpq-dev, git, etc.)
  - Instalar rbenv + ruby-build → rbenv install 3.3.0 && rbenv global 3.3.0
  - gem install rails → verificar rails -v (deve ser 8.x)
  - PostgreSQL no WSL2: sudo apt install postgresql + configurar usuário
  - Node.js via nvm (necessário para compilar Tailwind)
- VS Code abrir projeto via extensão Remote-WSL
- Extensões VS Code a instalar:
  - rebornix.Ruby, bung87.rails, castwide.solargraph (IntelliSense)
  - esbenp.prettier-vscode, humao.rest-client, eamodio.gitlens
  - ms-vscode-remote.remote-wsl
- MCPs: npm install -g @smithery/cli → adicionar Context7, Playwright, GitHub

## Phase 2 — Criar o Projeto Rails 8
- rails new kanbanflow --database=postgresql --css=tailwind dentro do WSL
- Configurar config/database.yml com credenciais do PostgreSQL local
- rails db:create → banco criado
- Explorar a estrutura MVC: app/models, app/controllers, app/views, config/routes.rb
- Adicionar ao Gemfile: rspec-rails, factory_bot_rails, faker, capybara, faker
- Criar repositório no GitHub via GitHub MCP e fazer primeiro commit

## Phase 3 — Autenticação (Rails 8 nativo, sem Devise)
- rails generate authentication → gera User, Session, PasswordResetToken
- rails db:migrate
- Criar RegistrationsController para signup (o generator não cria)
- Proteger rotas com before_action :require_authentication
- Navbar com links de Login / Logout / Cadastro usando Tailwind
- Referência: app/controllers/application_controller.rb usa Current.user

## Phase 4 — Models e ActiveRecord ORM
- rails g model Project user:references name:string description:text color:string
- rails g model Task project:references title:string description:text status:integer position:integer
- Validações: validates :name, presence: true, length: { maximum: 100 }
- Associations: User has_many :projects, Project has_many :tasks, dependent: :destroy
- Enum no Task: enum status: { todo: 0, in_progress: 1, done: 2 }
- Scopes: scope :by_status, ->(s) { where(status: s) }
- rails db:migrate

## Phase 4.1 — Integridade do Banco de Dados
- Migration com `null: false` nas colunas obrigatórias (`tasks.title`, `projects.name`)
- Índice em `tasks.status` para filtros sem full table scan
- Índice composto `[project_id, status]` — query mais frequente da API
- Índice em `tasks.position` para ordenação eficiente
- Confirmar constraints no schema.rb — banco garante integridade, não só o model

## Phase 5 — CRUD Completo (Projects + Tasks)
- Rotas aninhadas: resources :projects do; resources :tasks; end
- Controllers de Projects e Tasks com todas as 7 actions CRUD
- Views com Tailwind: lista de projetos em cards, formulários, board de tarefas
- Partials reutilizáveis: _project.html.erb, _task.html.erb
- Flash messages e redirecionamentos após cada action
- Autorização básica: usuário só acessa seus próprios projetos

## Phase 6 — Hotwire / Turbo (real-time sem JavaScript pesado)
- Turbo Drive já ativo — navegação SPA-like sem configuração
- Turbo Frame — formulário de nova task abre inline, sem reload de página
- Turbo Streams — quando task muda de status, coluna Kanban atualiza em tempo real
- task.rb: after_update_commit { broadcast_update_to "project_#{project_id}" }
- View do board: <%= turbo_stream_from "project_#{@project.id}" %>
- Stimulus Controller — drag-and-drop das tasks entre colunas (SortableJS + Stimulus)
- app/javascript/controllers/sortable_controller.js
- Demonstrar as 5 ações do Turbo Streams: append, prepend, update, remove, replace

## Phase 7 — API REST (/api/v1)
- Namespace em routes.rb: namespace :api do; namespace :v1 do; resources :projects; resources :tasks
- app/controllers/api/v1/base_controller.rb herdando ActionController::API
- Token authentication para a API (campo api_token no User)
- Endpoints JSON para Projects e Tasks (CRUD completo)
- respond_to nos controllers principais → mesma action serve HTML e JSON
- Arquivo .http no VS Code para testar todos os endpoints

## Phase 7.2 — Serialização e Paginação da API
- Extrair serialização para Jbuilder views (`app/views/api/v1/`) — controller orquestra, view serializa
- Gem `pagy` para paginação: `GET /api/v1/projects?page=1&per_page=20`
- Response envelope com metadados: `{ data: [...], meta: { current_page:, total_pages:, total_count: } }`
- Padronizar formato de erro: `{ error: "mensagem" }` com status HTTP correto em todos os endpoints
- Atualizar `api.http` com exemplos de paginação e cenários de erro

## Phase 8 — Testes com RSpec
- Confirmar factories (`spec/factories/`) com dados realistas via Faker
- Model specs reais: validações, associations, scopes, enum, callbacks — nenhum `pending`
- Request specs da API: todos os endpoints com auth Bearer (sucesso + falha + 401 + 404)
- Seeds em `db/seeds.rb`: 2 usuários, 3 projetos cada, tasks em statuses variados
- System specs (Capybara): cadastro → login → criar projeto → criar task → mover colunas → logout
- `bundle exec rspec --format documentation` — 100% passando
- SimpleCov com cobertura mínima de 80%

## Phase 8.1 — Segurança e Hardening
- Hash do API token com BCrypt — não armazenar token raw no banco
- Gem `rack-attack`: throttle por IP (60 req/min API, 5 logins/20s)
- Revisão de CSP para produção — bloquear inline scripts desnecessários
- `bin/brakeman` e `bin/bundler-audit` sem warnings antes do deploy
- Nenhuma credencial hardcoded — tudo via ENV ou Rails credentials

## Phase 9 — Deploy no Render.com
- Garantir gem 'pg' no Gemfile (não sqlite3)
- Criar bin/render-build.sh: bundle install + assets:precompile + db:migrate
- Push para GitHub
- No Render dashboard:
  - Criar PostgreSQL → copiar Internal Database URL
  - Criar Web Service → conectar repo do GitHub
  - Build Command: ./bin/render-build.sh
  - Start Command: bin/rails server -b 0.0.0.0
  - Variáveis de ambiente: DATABASE_URL, RAILS_MASTER_KEY, RAILS_ENV=production
- Deploy e verificar logs — app pública na internet

## Arquivos-chave do projeto final
- config/routes.rb — rotas aninhadas + namespace API
- app/models/task.rb — enum + scopes + Turbo broadcasts
- app/controllers/tasks_controller.rb — CRUD + respond_to
- app/controllers/api/v1/tasks_controller.rb — REST API pura
- app/views/api/v1/projects/_project.json.jbuilder — serialização JSON
- app/javascript/controllers/sortable_controller.js — drag-and-drop Stimulus
- app/views/projects/show.html.erb — board Kanban com Turbo Streams
- config/initializers/rack_attack.rb — rate limiting por IP
- spec/requests/api/v1/projects_spec.rb — request specs da API com auth
- spec/system/tasks_spec.rb — teste E2E Capybara
- db/seeds.rb — dados de exemplo para desenvolvimento
- bin/render-build.sh — script de deploy

## Verificação final
- `rails server` local sem erros
- `bundle exec rspec --format documentation` — todos os testes passando, cobertura ≥ 80%
- `GET /api/v1/projects?page=1` retorna dados + metadados de paginação
- `bin/brakeman --no-pager` e `bin/bundler-audit` sem nenhum warning
- `bundle exec rails db:seed` povoa o banco com dados de exemplo
- Criar task e ver coluna Kanban atualizar sem recarregar a página
- URL pública no Render funcionando com banco PostgreSQL em produção
- Esse plano cobre tudo da sua lista: Ruby, Rails 8, PostgreSQL, Tailwind, Hotwire/Turbo, MVC, ORM, CRUD, autenticação, frontend integrado e API REST — mais testes e deploy. Podemos começar pela Phase 1 (WSL2) quando quiser, ou quer ajustar algo no plano antes?
