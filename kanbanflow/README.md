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

## Pré-requisitos

- Ruby 3.4+
- PostgreSQL
- Node.js (para compilar assets Tailwind)

## Setup local

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/ruby.git
cd ruby/kanbanflow

# 2. Instalar dependências
bundle install

# 3. Configurar o banco de dados
# Edite config/database.yml se necessário (usuário/senha do PostgreSQL)
rails db:create db:migrate

# 4. Iniciar o servidor
bin/dev
```

Acesse `http://localhost:3000` e crie sua conta.

## Rodando os testes

```bash
bundle exec rspec                          # todos os testes
bundle exec rspec --format documentation   # output detalhado
bundle exec rspec spec/models/             # apenas model specs
bundle exec rspec spec/system/             # apenas testes E2E (Capybara)
```

## API REST

A API está disponível em `/api/v1`. Autentique com o header:

```
Authorization: Bearer SEU_API_TOKEN
```

Exemplos de endpoints:

```
GET    /api/v1/projects          # listar projetos
POST   /api/v1/projects          # criar projeto
GET    /api/v1/projects/:id      # detalhes do projeto
PATCH  /api/v1/projects/:id      # atualizar projeto
DELETE /api/v1/projects/:id      # excluir projeto

GET    /api/v1/projects/:id/tasks?status=todo   # filtrar tasks por status
POST   /api/v1/projects/:id/tasks               # criar task
PATCH  /api/v1/projects/:id/tasks/:id           # atualizar task (mover colunas)
```

## Deploy no Render.com

1. Fork o repositório e conecte no [Render.com](https://render.com)
2. Crie um PostgreSQL no Render e copie a **Internal Database URL**
3. Crie um Web Service com:
   - **Build Command:** `./bin/render-build.sh`
   - **Start Command:** `bin/rails server -b 0.0.0.0`
4. Configure as variáveis de ambiente:
   - `DATABASE_URL` → Internal Database URL do PostgreSQL
   - `RAILS_MASTER_KEY` → conteúdo do arquivo `config/master.key`
   - `RAILS_ENV` → `production`

## Estrutura do projeto

```
kanbanflow/
├── app/
│   ├── controllers/
│   │   ├── api/v1/          # API REST (JSON)
│   │   ├── sessions_controller.rb
│   │   ├── registrations_controller.rb
│   │   └── projects_controller.rb
│   ├── models/
│   │   ├── user.rb          # autenticação + associations
│   │   ├── project.rb       # has_many tasks
│   │   └── task.rb          # enum status + Turbo broadcasts
│   ├── javascript/
│   │   └── controllers/
│   │       └── sortable_controller.js  # drag-and-drop
│   └── views/
│       └── projects/
│           └── show.html.erb  # board Kanban + Turbo Streams
├── config/
│   └── routes.rb              # rotas aninhadas + namespace API
├── spec/                      # testes RSpec
└── bin/
    └── render-build.sh        # script de deploy
```

## Roadmap de aprendizado

- [x] Phase 1: Setup WSL2 + Ruby 3.4 + PostgreSQL
- [x] Phase 2: Criar projeto Rails 8 + banco de dados
- [x] Phase 3: Autenticação nativa Rails 8
- [ ] Phase 4: Models (Project, Task) + ActiveRecord ORM
- [ ] Phase 5: CRUD completo com Tailwind
- [ ] Phase 6: Hotwire/Turbo real-time
- [ ] Phase 7: API REST `/api/v1`
- [ ] Phase 8: Testes com RSpec
- [ ] Phase 9: Deploy no Render.com

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
