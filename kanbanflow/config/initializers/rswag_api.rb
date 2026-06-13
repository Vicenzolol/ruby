Rswag::Api.configure do |c|

  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
  # that it's configured to generate files in the same folder
  c.openapi_root = Rails.root.to_s + '/swagger'

  # Injeta o servidor correto (dev ou produção) dinamicamente a partir do request
  c.swagger_filter = lambda { |swagger, env|
    scheme = env["rack.url_scheme"] || "https"
    host   = env["HTTP_HOST"] || env["SERVER_NAME"]
    swagger["servers"] = [ { "url" => "#{scheme}://#{host}", "description" => "Servidor atual" } ]
  }
end
