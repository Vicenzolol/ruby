# Aprendendo Ruby on Rails 8

Repositório de aprendizado prático de **Ruby on Rails 8** — construindo um projeto real do zero ao deploy, cobrindo todos os conceitos essenciais do framework.

## O projeto: Aprendendo e Fazendo Kanban

Um gerenciador de tarefas Kanban com atualizações em tempo real. Escolhido por cobrir naturalmente todos os tópicos relevantes: autenticação, CRUD, ORM, real-time, API REST, testes e deploy.

**→ [Documentação completa do projeto](kanbanflow/README.md)**

## Tecnologias

| | Tecnologia | Por quê |
|---|---|---|
| 🔴 | Ruby 3.4 | Linguagem principal — elegante, expressiva |
| 🚂 | Rails 8.1 | Framework MVC full-stack mais produtivo |
| 🐘 | PostgreSQL | Banco relacional robusto para produção |
| 🎨 | Tailwind CSS 4 | Estilização sem sair do HTML |
| ⚡ | Hotwire (Turbo + Stimulus) | Real-time sem escrever muito JavaScript |
| 🧪 | RSpec + Capybara | Testes unitários e E2E |
| 🚀 | Render.com | Deploy gratuito com PostgreSQL gerenciado |

## Neste repositório

```
ruby/
├── kanbanflow/        ← Aplicação Rails (código principal)
│   ├── app/           ← Models, Controllers, Views
│   ├── config/        ← Rotas, banco, inicializadores
│   ├── db/            ← Migrations e schema
│   ├── spec/          ← Testes RSpec
│   └── README.md      ← Docs: setup, rotas, API, deploy
├── CHANGELOG.md       ← Histórico de mudanças por fase
└── plan.md            ← Plano completo de aprendizado (todas as fases)
```

## Roadmap de aprendizado

| Fase | Tópico | Status |
|---|---|---|
| 1 | Setup WSL2 + Ruby + PostgreSQL | ✅ Concluído |
| 2 | Criar projeto Rails 8 + banco de dados | ✅ Concluído |
| 3 | Autenticação nativa Rails 8 (sem Devise) | ✅ Concluído |
| 4 | Models com ActiveRecord ORM (validações, associations, enums, scopes) | ✅ Concluído |
| 5 | CRUD completo com Tailwind CSS | ✅ Concluído |
| 6 | Hotwire/Turbo real-time (Frames + Streams + Stimulus) | ✅ Concluído |
| 7 | API REST `/api/v1` com autenticação por token | ✅ Concluído |
| 8 | Testes com RSpec (model, request, system specs) | ⬜ Planejado |
| 9 | Deploy no Render.com | ⬜ Planejado |

**→ [Ver histórico detalhado de mudanças](CHANGELOG.md)**
**→ [Ver plano completo](plan.md)**

## Links úteis

- [Ruby on Rails Guides](https://guides.rubyonrails.org/) — documentação oficial
- [ruby-lang.org/pt](https://www.ruby-lang.org/pt/) — Ruby em português
- [Hotwire](https://hotwired.dev/) — Turbo + Stimulus
- [Tailwind CSS](https://tailwindcss.com/) — utilitários CSS