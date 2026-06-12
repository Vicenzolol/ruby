# Aprendendo e Fazendo Kanban

Gerenciador de tarefas Kanban com atualizações em tempo real, construído em **Ruby on Rails 8** como projeto de aprendizado completo — cobrindo autenticação, CRUD, Hotwire/Turbo, API REST, testes e deploy.

## Stack

| Camada | Tecnologia |
|---|---|
| Backend | Ruby 3.4 + Rails 8.1 |
| Banco de dados | PostgreSQL |
| Frontend | Tailwind CSS 4 + Hotwire (Turbo + Stimulus) |
| Autenticação | Rails 8 Authentication Generator (sem Devise) |
| Testes | RSpec + FactoryBot + Capybara + Faker |
| Deploy | Render.com |

## Funcionalidades

- Autenticação completa (cadastro, login, logout, redefinição de senha)
- Gerenciamento de projetos (criar, editar, excluir)
- Board Kanban com colunas: **A Fazer**, **Em Andamento**, **Concluído**
- Drag-and-drop de tarefas entre colunas (Stimulus + SortableJS)
- Atualizações em tempo real sem recarregar a página (Turbo Streams)
- API REST em `/api/v1` com autenticação por token
- Interface totalmente responsiva com Tailwind CSS

---

## Como rodar localmente

### Pré-requisitos

- Ruby 3.4+ (via rbenv)
- PostgreSQL (rodando no WSL2)
- Node.js 20+

### Setup

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/ruby.git
cd ruby/kanbanflow

# 2. Instalar dependências Ruby
bundle install

# 3. Criar e migrar o banco de dados
bundle exec rails db:create db:migrate

# 4. Iniciar servidor + Tailwind
bin/dev
```

### Acessar a interface web

Com o servidor rodando, abra no navegador:

```
http://localhost:3000
```

- **Página inicial** → formulário de login
- **Criar conta** → `http://localhost:3000/registration/new`
- **Login** → `http://localhost:3000/session/new`
- **Emails interceptados** → `http://localhost:3000/letter_opener` (apenas em desenvolvimento)

---

## Acessar o banco de dados

### Pelo terminal (psql)

```bash
# Conectar ao banco de desenvolvimento
psql -U vicen -d kanbanflow_development

# Comandos úteis dentro do psql
\dt              # listar todas as tabelas
\d users         # ver estrutura da tabela users
SELECT * FROM users;
\q               # sair
```

### Pela extensão "Database Client" no VS Code

Preencha o formulário de conexão com:

| Campo | Valor |
|---|---|
| Tipo de servidor | PostgreSQL |
| Host | `127.0.0.1` |
| Porta | `5432` |
| Nome de usuário | `vicen` |
| Senha | `kanban_dev_2026` |
| Banco de dados | `kanbanflow_development` |

> Para ver o banco de testes, troque para `kanbanflow_test`.

### Pelo Rails console

```bash
# Console interativo com acesso total ao banco via ORM
bundle exec rails console

# Exemplos dentro do console
User.all
User.first.email_address
User.count
```

---

## Rotas da aplicação

```
# Interface web
GET    /                        → login (root)
GET    /session/new             → formulário de login
POST   /session                 → autenticar (criar sessão)
DELETE /session                 → logout
GET    /registration/new        → cadastro
POST   /registration            → criar conta
GET    /passwords/new           → esqueci minha senha
GET    /passwords/:token/edit   → redefinir senha
PATCH  /passwords/:token        → salvar nova senha

# Projetos (autenticado)
GET    /projects                → lista de projetos
GET    /projects/new            → novo projeto
POST   /projects                → criar projeto
GET    /projects/:id            → board Kanban do projeto
GET    /projects/:id/edit       → editar projeto
PATCH  /projects/:id            → salvar edição
DELETE /projects/:id            → excluir projeto

# Tasks (aninhadas nos projetos)
POST   /projects/:id/tasks               → criar task
GET    /projects/:id/tasks/:id/edit      → editar task
PATCH  /projects/:id/tasks/:id           → atualizar task (mover colunas)
DELETE /projects/:id/tasks/:id           → excluir task
```

### API REST (`/api/v1`)

Autentique com o header `Authorization: Bearer SEU_API_TOKEN`.

```
GET    /api/v1/projects
POST   /api/v1/projects
GET    /api/v1/projects/:id
PATCH  /api/v1/projects/:id
DELETE /api/v1/projects/:id

GET    /api/v1/projects/:id/tasks?status=todo
POST   /api/v1/projects/:id/tasks
PATCH  /api/v1/projects/:id/tasks/:id
DELETE /api/v1/projects/:id/tasks/:id
```

> Teste os endpoints com o arquivo [`api.http`](api.http) usando a extensão REST Client do VS Code.

#### CORS

A API aceita requisições cross-origin de `localhost:3000` (configurado em `config/initializers/cors.rb` via `rack-cors`).
Para permitir outras origens (ex.: frontend em produção), adicione-as ao bloco `origins` do inicializador.

---

## Rodando os testes

```bash
bundle exec rspec                          # todos os testes
bundle exec rspec --format documentation   # output detalhado
bundle exec rspec spec/models/             # model specs
bundle exec rspec spec/requests/           # request specs (API)
bundle exec rspec spec/system/             # testes E2E (Capybara)
```

---

## Deploy no Render.com

O projeto inclui `render.yaml` (na raiz do repositório) que automatiza a criação
de todos os serviços via [Render Blueprint](https://render.com/docs/infrastructure-as-code).

### Deploy com Blueprint (recomendado)

1. Faça fork e conecte o repositório no [Render.com](https://render.com)
2. Crie um novo **Blueprint** apontando para este repositório
3. O Render detecta o `render.yaml` e cria automaticamente:
   - Web Service (Ruby nativo, free tier)
   - PostgreSQL database (free tier, 90 dias)
4. Configure o secret `RAILS_MASTER_KEY` no painel do Render:
   - Dashboard → Web Service → Environment → Secret Files
   - Valor: conteúdo do arquivo `kanbanflow/config/master.key`

### Variáveis de ambiente

| Variável | Como configurar |
|---|---|
| `RAILS_MASTER_KEY` | Manual — conteúdo de `config/master.key` (nunca comite!) |
| `DATABASE_URL` | Automático — injetado pelo Render via `render.yaml` |
| `RENDER_EXTERNAL_URL` | Automático — URL pública da aplicação |
| `WEB_CONCURRENCY` | Configurado no `render.yaml` (valor: `1` para free tier) |

### Estrutura do deploy

```
render.yaml (raiz do repositório)
  └── Web Service
        rootDir: kanbanflow
        buildCommand: bin/render-build.sh  →  bundle install
                                              rails assets:precompile
                                              rails db:migrate
        startCommand: bin/rails server
        healthCheckPath: /up
  └── PostgreSQL (kanbanflow-db)
        DATABASE_URL → injetado automaticamente
```

### Limitações do free tier

- **Web Service**: hiberna após 15 min de inatividade; primeiro request demora ~30s
- **PostgreSQL**: expira após 90 dias (free tier); dados são perdidos
- **ActionCable**: usa adapter `async` (single-server); sem Turbo Streams entre múltiplos workers

---

## Estrutura do projeto

```
kanbanflow/
├── app/
│   ├── controllers/
│   │   ├── api/v1/                      # API REST (JSON)
│   │   ├── concerns/authentication.rb   # lógica de auth
│   │   ├── sessions_controller.rb       # login/logout
│   │   ├── registrations_controller.rb  # cadastro
│   │   └── projects_controller.rb       # CRUD projetos
│   ├── models/
│   │   ├── user.rb          # autenticação + validações
│   │   ├── session.rb       # sessões ativas
│   │   ├── current.rb       # Current.user global
│   │   ├── project.rb       # has_many tasks
│   │   └── task.rb          # enum status + Turbo broadcasts
│   ├── javascript/
│   │   └── controllers/
│   │       └── sortable_controller.js   # drag-and-drop
│   └── views/
│       └── projects/
│           └── show.html.erb            # board Kanban + Turbo Streams
├── config/
│   └── routes.rb                        # rotas aninhadas + namespace API
├── db/
│   ├── migrate/                         # histórico de migrations
│   └── schema.rb                        # estado atual do banco
├── spec/                                # testes RSpec
└── bin/
    └── render-build.sh                  # script de deploy
```

## Documentação

| Documento | Conteúdo |
|---|---|
| [CHANGELOG.md](../CHANGELOG.md) | Histórico de funcionalidades por fase |
| [BUGFIX.md](../BUGFIX.md) | Registro de bugs encontrados e corrigidos |
| [plan.md](../plan.md) | Plano completo de aprendizado |

