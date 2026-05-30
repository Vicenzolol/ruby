# config/initializers/rack_attack.rb
# Rate limiting e proteção contra força bruta via Rack::Attack
# Documentação: https://github.com/rack/rack-attack

# ─── Throttles ───────────────────────────────────────────────────────────────

# 1. Throttle geral na API por IP: 60 req/minuto
Rack::Attack.throttle("api/ip", limit: 60, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/api/")
end

# 2. Throttle de login por IP: 5 tentativas por 20 segundos
Rack::Attack.throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
  req.ip if req.path == "/session" && req.post?
end

# 3. Throttle de login por e-mail normalizado: 5 tentativas por 20 segundos
#    Previne bypass via variações de e-mail (maiúsculas, espaços)
Rack::Attack.throttle("logins/email", limit: 5, period: 20.seconds) do |req|
  if req.path == "/session" && req.post?
    req.params["email"].to_s.downcase.strip.presence
  end
end

# 4. Throttle de reset de senha por IP: 5 tentativas por hora
Rack::Attack.throttle("passwords/ip", limit: 5, period: 1.hour) do |req|
  req.ip if req.path == "/passwords" && req.post?
end

# ─── Resposta personalizada para 429 ─────────────────────────────────────────

Rack::Attack.throttled_responder = lambda do |req|
  match_data = req.env["rack.attack.match_data"]
  now        = match_data[:epoch_time]
  retry_after = (match_data[:period] - (now % match_data[:period])).to_i

  headers = {
    "Content-Type" => "application/json",
    "Retry-After"  => retry_after.to_s
  }

  body = { error: "Muitas requisições. Tente novamente em #{retry_after}s." }.to_json
  [ 429, headers, [ body ] ]
end
