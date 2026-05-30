require "rails_helper"
require "rswag/specs"

# Este arquivo é o ponto de entrada das specs rswag.
# Ele define o schema OpenAPI 3.0 que será gerado em swagger/v1/swagger.yaml
# ao rodar: bundle exec rails rswag  (RAILS_ENV=test)

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "KanbanFlow API V1",
        version: "v1",
        description: <<~DESC
          API REST para gerenciamento de projetos e tarefas Kanban.
          Autenticação via Bearer token — obtenha o token em `GET /api/v1/me`.
          Todos os endpoints de listagem suportam paginação via `?page=` e `?per_page=`.
        DESC
      },
      paths: {},
      components: {
        schemas: {
          Project: {
            type: :object,
            properties: {
              id:          { type: :integer, example: 1 },
              name:        { type: :string,  example: "Redesign do Site" },
              description: { type: :string,  nullable: true, example: "Reformular toda a identidade visual" },
              color:       { type: :string,  example: "#3b82f6" },
              tasks_count: { type: :integer, example: 5 },
              created_at:  { type: :string,  format: :"date-time" },
              updated_at:  { type: :string,  format: :"date-time" }
            },
            required: %w[id name tasks_count created_at updated_at]
          },
          ProjectWithTasks: {
            allOf: [
              { "$ref" => "#/components/schemas/Project" },
              {
                type: :object,
                properties: {
                  tasks: {
                    type: :array,
                    items: { "$ref" => "#/components/schemas/Task" }
                  }
                },
                required: %w[tasks]
              }
            ]
          },
          Task: {
            type: :object,
            properties: {
              id:          { type: :integer, example: 1 },
              project_id:  { type: :integer, example: 1 },
              title:       { type: :string,  example: "Implementar autenticação" },
              description: { type: :string,  nullable: true },
              status:      { type: :string,  enum: %w[todo in_progress done], example: "todo" },
              position:    { type: :integer, example: 1 },
              created_at:  { type: :string,  format: :"date-time" },
              updated_at:  { type: :string,  format: :"date-time" }
            },
            required: %w[id project_id title status position]
          },
          PaginationMeta: {
            type: :object,
            properties: {
              current_page: { type: :integer, example: 1 },
              total_pages:  { type: :integer, example: 3 },
              total_count:  { type: :integer, example: 42 },
              per_page:     { type: :integer, example: 20 }
            },
            required: %w[current_page total_pages total_count per_page]
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: "Não autorizado." }
            },
            required: %w[error]
          }
        },
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            description: "Token do usuário — obtido em GET /api/v1/me. " \
                         "Inclua como: Authorization: Bearer <token>"
          }
        }
      },
      security:  [ { bearerAuth: [] } ],
      servers: [
        { url: "http://localhost:3000", description: "Desenvolvimento local" }
      ]
    }
  }

  # Formato de saída: yaml é mais legível e fácil de versionar
  config.openapi_format = :yaml
end
