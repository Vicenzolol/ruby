Rswag::Ui.configure do |c|
  # Endpoint OpenAPI servido pelo rswag-api. Gerado via:
  #   bundle exec rails rswag  (em RAILS_ENV=test)
  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'KanbanFlow API V1'
end
