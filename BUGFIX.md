# Registro de Correções de Bugs

Correções de problemas encontrados durante o desenvolvimento.
Cada entrada inclui o contexto, causa raiz e solução aplicada.

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
