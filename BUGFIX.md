# Registro de Correções de Bugs

Correções de problemas encontrados durante o desenvolvimento.
Cada entrada inclui o contexto, causa raiz e solução aplicada.

---

## BUG-004 — Build Docker falha com `KeyError: key not found: "RESEND_API_KEY"`

**Data:** 2026-06-12
**Severidade:** Crítica — impede deploy no Render.com completamente

### Sintoma

O build Docker no Render.com falha no estágio `assets:precompile` com:

```
KeyError: key not found: "RESEND_API_KEY"
/rails/config/environments/production.rb:73:in 'fetch'
```

### Causa raiz

`config/environments/production.rb` usava `ENV.fetch("RESEND_API_KEY")` (sem valor padrão) na configuração SMTP de `action_mailer`. O Rails carrega o arquivo de configuração de ambiente durante `assets:precompile`, mas nesse estágio do build Docker as variáveis de ambiente de runtime (como `RESEND_API_KEY`) ainda não estão injetadas — apenas `SECRET_KEY_BASE_DUMMY=1` é passado. O `fetch` sem fallback lança `KeyError` imediatamente.

### Solução

Alterado para `ENV.fetch("RESEND_API_KEY", nil)` em [kanbanflow/config/environments/production.rb:73](kanbanflow/config/environments/production.rb). O valor `nil` é seguro pois nenhum e-mail é enviado durante a compilação de assets; a chave real estará disponível em runtime no Render.

---

## BUG-002 — Tela de login exibida mesmo após autenticação

**Data:** 2026-06-12
**Severidade:** Média — experiência quebrada; usuário logado via `/` via tela de login repetidamente

### Sintoma

Após fazer login, o usuário permanecia na tela de login (`/`) em vez de ser redirecionado ao dashboard. Ao acessar `http://localhost:3000/` já estando logado, a tela de login era exibida novamente sem qualquer aviso ou redirecionamento.

### Causa raiz

Dois problemas encadeados:

| # | Arquivo | Problema |
|---|---|---|
| 1 | `config/routes.rb` | `root "sessions#new"` fazia a raiz `/` apontar para a tela de login para todos, autenticados ou não |
| 2 | `authentication.rb` | `after_authentication_url` devolvia `root_url` que, sendo `sessions#new`, redirecionava o recém-logado de volta à tela de login |

### Solução aplicada

- `config/routes.rb`: `root` alterado para `"projects#index"`. O concern `Authentication` já chama `require_authentication` em projetos, então usuários não autenticados são redirecionados para login automaticamente.
- `sessions_controller.rb#new`: adicionado `redirect_to root_path if authenticated?` para evitar que usuários já logados vejam a tela de login.
- `sessions_controller.rb#create`: adicionado `notice: "Logado com sucesso!"` ao redirect para dar feedback visual imediato.

---

## BUG-003 — Email de reset de senha não era entregue

**Data:** 2026-06-12
**Severidade:** Alta — funcionalidade de recuperação de senha completamente inoperante em produção

### Sintoma

Ao clicar em "Esqueci minha senha" e submeter o formulário, a aplicação exibia a mensagem de sucesso normalmente, mas o email nunca chegava ao destinatário.

### Causa raiz

Três problemas encadeados:

| # | Arquivo | Problema |
|---|---|---|
| 1 | `config/environments/production.rb` | Bloco `smtp_settings` comentado — Rails sem delivery method configurado usava `:test` (descarta os emails silenciosamente) |
| 2 | `app/mailers/application_mailer.rb` | `from: "from@example.com"` — endereço inválido rejeitado por servidores SMTP |
| 3 | `app/controllers/passwords_controller.rb` | `deliver_later` com `queue_adapter: :async` — jobs enfileirados na memória são perdidos quando o Render (free tier) coloca o processo em sleep |

### Solução aplicada

- `production.rb`: SMTP configurado para `smtp.resend.com:587` com autenticação via `RESEND_API_KEY` (env var no Render)
- `application_mailer.rb`: `from:` substituído por `ENV.fetch("MAILER_FROM", "onboarding@resend.dev")` — configurável via env sem redeploy
- `passwords_controller.rb`: `deliver_later` → `deliver_now` para evitar perda de jobs em instâncias efêmeras

### Configuração necessária no Render

| Variável | Valor |
|---|---|
| `RESEND_API_KEY` | chave gerada no painel do Resend |
| `MAILER_FROM` | `noreply@seudominio.com` (após verificar domínio no Resend) |

---

## BUG-001 — Tailwind CSS sem efeito na interface

**Data:** 2026-05-20  
**Fase relacionada:** Phase 5 (CRUD + Tailwind CSS)  
**Severidade:** Alta — toda a interface aparecia sem estilo algum

### Sintoma

Ao rodar `bin/dev` e acessar `http://127.0.0.1:3000`, a página carregava o HTML corretamente com todas as classes Tailwind presentes no código, mas nenhum estilo era aplicado. A interface ficava com layout de texto puro (sem cores, sem espaçamentos, sem cards).

### Causas raiz (4 problemas encadeados)

| # | Arquivo | Problema |
|---|---|---|
| 1 | `app/assets/tailwind/` | Diretório e arquivo de entrada do Tailwind v4 nunca foram criados |
| 2 | `app/assets/builds/` | CSS compilado nunca existiu — `tailwindcss:build` nunca foi executado |
| 3 | `app/views/layouts/application.html.erb` | `stylesheet_link_tag :app` procurava `app.css` (inexistente com Propshaft) em vez de `tailwind` |
| 4 | `bin/dev` | Executava apenas `rails server`, sem iniciar o watcher do Tailwind; e dependia do `foreman` que não estava no PATH do rbenv |

### Contexto técnico

O projeto usa **Propshaft** como pipeline de assets (não Sprockets). Com Propshaft, `stylesheet_link_tag :app` resolve para `/assets/app.css` literalmente — não é um bundle nem um manifest. Como não existia `app.css`, nenhuma folha de estilo era carregada.

O `tailwindcss-rails` v4 exige:
- Um arquivo de entrada CSS em `app/assets/tailwind/application.css` com `@import "tailwindcss";`  
- Compilação para `app/assets/builds/tailwind.css` via `rails tailwindcss:build`
- Referência explícita na view via `stylesheet_link_tag "tailwind"`

### Solução aplicada

**1. Configuração inicial do Tailwind** — executado o gerador oficial:
```bash
bin/rails tailwindcss:install
```
Isso criou `app/assets/tailwind/application.css`, `app/assets/builds/`, compilou o CSS inicial e instalou o `foreman`.

**2. Correção do layout** (`app/views/layouts/application.html.erb`):
```erb
# Antes (quebrado)
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>

# Depois (correto)
<%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
```

**3. Reescrita do `bin/dev`** — removida dependência do `foreman` (que não estava no PATH do rbenv), substituído por processos nativos em background:
```sh
# Antes (quebrado)
exec foreman start -f Procfile.dev "$@"

# Depois (sem dependência externa)
trap 'kill 0' EXIT INT TERM
bin/rails tailwindcss:watch &
bin/rails server -p "${PORT}" &
wait
```

### Lição aprendida

Ao instalar a gem `tailwindcss-rails` em um projeto Rails 8, **sempre executar `bin/rails tailwindcss:install`** antes de iniciar o servidor. A gem não auto-configura o pipeline — o gerador é obrigatório para criar os arquivos de entrada e compilar o CSS inicial.

Com Propshaft, cada stylesheet precisa ser referenciada explicitamente pelo nome do arquivo compilado (`"tailwind"`), não por símbolos ou nomes de bundle como no Sprockets (`:app`, `:all`).

---

*Para histórico de funcionalidades adicionadas, veja [CHANGELOG.md](CHANGELOG.md).*
