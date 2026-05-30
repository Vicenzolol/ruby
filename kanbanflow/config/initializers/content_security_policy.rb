# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, :blob
    policy.object_src  :none

    # Scripts: apenas :self + nonce (importmap usa inline scripts com nonce)
    policy.script_src :self

    # Estilos: :self e :unsafe_inline (Tailwind CSS compilado + Swagger UI)
    policy.style_src :self, :unsafe_inline

    # WebSockets para ActionCable / Turbo Streams (ws em dev, wss em prod)
    policy.connect_src :self, "ws://localhost:3000", "wss://localhost:3000",
                       "ws://127.0.0.1:3000",  "wss://127.0.0.1:3000"

    # Anti-clickjacking
    policy.frame_ancestors :none
  end

  # Gera um nonce único por request — adicionado automaticamente a script tags
  # pelo helper javascript_importmap_tags, javascript_include_tag, etc.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Ativa o nonce automático em javascript_tag e javascript_include_tag
  config.content_security_policy_nonce_auto = true
end
