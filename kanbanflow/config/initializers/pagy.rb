# Configuração global da gem pagy (paginação) — v43+
# Documentação: https://ddnexus.github.io/pagy/

# Carrega o módulo Method (paginator padrão do pagy v43+)
require "pagy/toolbox/paginators/method"

Pagy::OPTIONS[:limit]     = 20   # itens por página (padrão)
Pagy::OPTIONS[:max_limit] = 100  # limite máximo aceitável por requisição
