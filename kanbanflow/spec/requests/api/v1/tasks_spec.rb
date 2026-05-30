require "swagger_helper"

RSpec.describe "API V1 — Tasks", type: :request do
  let(:user)          { create(:user) }
  let(:project)       { create(:project, user: user) }
  let(:Authorization) { "Bearer #{user.api_token}" }

  # ─────────────────────────────────────────────────────────────────────────────
  # GET /api/v1/projects/:project_id/tasks
  # ─────────────────────────────────────────────────────────────────────────────
  path "/api/v1/projects/{project_id}/tasks" do
    parameter name: :project_id, in: :path,
              schema: { type: :integer },
              required: true,
              description: "ID do projeto"

    let(:project_id) { project.id }

    get "Lista tarefas do projeto (paginado, filtrável por status)" do
      tags        "Tasks"
      produces    "application/json"
      security    [ { bearerAuth: [] } ]
      parameter name: :status, in: :query,
                schema: { type: :string, enum: %w[todo in_progress done] },
                required: false,
                description: "Filtra por status da coluna Kanban"
      parameter name: :page,     in: :query,
                schema: { type: :integer, default: 1 },
                required: false,
                description: "Número da página"
      parameter name: :per_page, in: :query,
                schema: { type: :integer, default: 20 },
                required: false,
                description: "Itens por página (máx. 100)"

      response "200", "lista de tarefas com metadados de paginação" do
        schema type: :object,
               properties: {
                 data: { type: :array, items: { "$ref" => "#/components/schemas/Task" } },
                 meta: { "$ref" => "#/components/schemas/PaginationMeta" }
               },
               required: %w[data meta]

        before { create_list(:task, 3, project: project, status: :todo) }
        run_test!
      end

      response "401", "não autorizado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { "Bearer invalido" }
        run_test!
      end

      response "404", "projeto não encontrado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:project_id) { 999_999 }
        run_test!
      end
    end

    # ─────────────────────────────────────────────────────────────────────────
    # POST /api/v1/projects/:project_id/tasks
    # ─────────────────────────────────────────────────────────────────────────
    post "Cria uma tarefa no projeto" do
      tags        "Tasks"
      consumes    "application/json"
      produces    "application/json"
      security    [ { bearerAuth: [] } ]
      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title:       { type: :string, example: "Implementar login" },
              description: { type: :string, example: "Descrição opcional" },
              status:      { type: :string, enum: %w[todo in_progress done], example: "todo" }
            },
            required: %w[title]
          }
        }
      }

      response "201", "tarefa criada com sucesso" do
        schema "$ref" => "#/components/schemas/Task"
        let(:body_params) { { task: { title: "Nova Tarefa via Swagger", status: "todo" } } }
        run_test!
      end

      response "422", "parâmetros inválidos" do
        schema "$ref" => "#/components/schemas/Error"
        let(:body_params) { { task: { title: "" } } }
        run_test!
      end

      response "401", "não autorizado" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { "Bearer invalido" }
        let(:body_params)   { { task: { title: "X" } } }
        run_test!
      end
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # GET / PATCH / DELETE /api/v1/tasks/:id
  # ─────────────────────────────────────────────────────────────────────────────
  path "/api/v1/tasks/{id}" do
    parameter name: :id, in: :path,
              schema: { type: :integer },
              required: true,
              description: "ID da tarefa"

    let(:task) { create(:task, project: project) }
    let(:id)   { task.id }

    get "Exibe uma tarefa" do
      tags     "Tasks"
      produces "application/json"
      security [ { bearerAuth: [] } ]

      response "200", "tarefa encontrada" do
        schema "$ref" => "#/components/schemas/Task"
        run_test!
      end

      response "404", "tarefa não encontrada ou de outro usuário" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end
    end

    patch "Atualiza uma tarefa (inclusive move entre colunas via status)" do
      tags     "Tasks"
      consumes "application/json"
      produces "application/json"
      security [ { bearerAuth: [] } ]
      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title:       { type: :string },
              description: { type: :string },
              status:      { type: :string, enum: %w[todo in_progress done] }
            }
          }
        }
      }

      response "200", "tarefa atualizada" do
        schema "$ref" => "#/components/schemas/Task"
        let(:body_params) { { task: { status: "in_progress" } } }
        run_test!
      end

      response "422", "parâmetros inválidos" do
        schema "$ref" => "#/components/schemas/Error"
        let(:body_params) { { task: { title: "" } } }
        run_test!
      end

      response "404", "tarefa não encontrada" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id)          { 999_999 }
        let(:body_params) { { task: { status: "done" } } }
        run_test!
      end
    end

    delete "Remove uma tarefa" do
      tags     "Tasks"
      security [ { bearerAuth: [] } ]

      response "204", "tarefa removida com sucesso" do
        run_test!
      end

      response "404", "tarefa não encontrada" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 999_999 }
        run_test!
      end
    end
  end
end
