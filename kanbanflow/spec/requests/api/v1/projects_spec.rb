require "swagger_helper"

RSpec.describe "API V1 — Projects", type: :request do
  let(:user)          { create(:user) }
  let(:Authorization) { "Bearer #{user.api_token}" }

  # ─────────────────────────────────────────────────────────────────────────────
  # GET /api/v1/projects
  # ─────────────────────────────────────────────────────────────────────────────
  path "/api/v1/projects" do
    get "Lista projetos do usuário autenticado (paginado)" do
      tags        "Projects"
      produces    "application/json"
      security    [ { bearerAuth: [] } ]
      parameter name: :page,     in: :query,
                schema: { type: :integer, default: 1 },
                required: false,
                description: "Número da página"
      parameter name: :per_page, in: :query,
                schema: { type: :integer, default: 20 },
                required: false,
                description: "Itens por página (máx. 100)"

      response "200", "lista de projetos com metadados de paginação" do
        schema type: :object,
               properties: {
                 data: { type: :array, items: { "$ref" => "#/components/schemas/Project" } },
                 meta: { "$ref" => "#/components/schemas/PaginationMeta" }
               },
               required: %w[data meta]

        before { create_list(:project, 3, user: user) }
        run_test!
      end

      response "401", "não autorizado — token ausente ou inválido" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { "Bearer token_invalido" }
        run_test!
      end
    end

    # ─────────────────────────────────────────────────────────────────────────
    # POST /api/v1/projects
    # ─────────────────────────────────────────────────────────────────────────
    post "Cria um novo projeto" do
      tags        "Projects"
      consumes    "application/json"
      produces    "application/json"
      security    [ { bearerAuth: [] } ]
      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          project: {
            type: :object,
            properties: {
              name:        { type: :string,  example: "Novo Projeto" },
              description: { type: :string,  example: "Descrição opcional" },
              color:       { type: :string,  example: "#3b82f6" }
            },
            required: %w[name]
          }
        }
      }

      response "201", "projeto criado com sucesso" do
        schema "$ref" => "#/components/schemas/ProjectWithTasks"
        let(:body_params) { { project: { name: "Projeto Swagger", color: "#3b82f6" } } }
        run_test!
      end

      response "422", "parâmetros inválidos" do
        schema "$ref" => "#/components/schemas/Error"
        let(:body_params) { { project: { name: "" } } }
        run_test!
      end

      response "401", "não autorizado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { "Bearer invalido" }
        let(:body_params)   { { project: { name: "X" } } }
        run_test!
      end
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # GET / PATCH / DELETE /api/v1/projects/:id
  # ─────────────────────────────────────────────────────────────────────────────
  path "/api/v1/projects/{id}" do
    parameter name: :id, in: :path,
              schema: { type: :integer },
              required: true,
              description: "ID do projeto"

    let(:project) { create(:project, user: user) }
    let(:id)      { project.id }

    get "Exibe um projeto com suas tarefas" do
      tags     "Projects"
      produces "application/json"
      security [ { bearerAuth: [] } ]

      response "200", "projeto com lista de tarefas" do
        schema "$ref" => "#/components/schemas/ProjectWithTasks"
        before { create_list(:task, 2, project: project) }
        run_test!
      end

      response "404", "projeto não encontrado ou pertence a outro usuário" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end

      response "401", "não autorizado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { "Bearer invalido" }
        run_test!
      end
    end

    patch "Atualiza um projeto" do
      tags     "Projects"
      consumes "application/json"
      produces "application/json"
      security [ { bearerAuth: [] } ]
      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          project: {
            type: :object,
            properties: {
              name:        { type: :string },
              description: { type: :string },
              color:       { type: :string }
            }
          }
        }
      }

      response "200", "projeto atualizado" do
        schema "$ref" => "#/components/schemas/ProjectWithTasks"
        let(:body_params) { { project: { name: "Nome Atualizado" } } }
        run_test!
      end

      response "422", "parâmetros inválidos" do
        schema "$ref" => "#/components/schemas/Error"
        let(:body_params) { { project: { name: "" } } }
        run_test!
      end

      response "404", "projeto não encontrado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id)          { 999_999 }
        let(:body_params) { { project: { name: "X" } } }
        run_test!
      end
    end

    delete "Remove um projeto e suas tarefas" do
      tags     "Projects"
      security [ { bearerAuth: [] } ]

      response "204", "projeto removido com sucesso" do
        run_test!
      end

      response "404", "projeto não encontrado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end
    end
  end
end
