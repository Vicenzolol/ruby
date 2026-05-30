class AddDatabaseConstraintsAndIndexes < ActiveRecord::Migration[8.1]
  def up
    # ── Integridade: null: false nas colunas obrigatórias ──────────────────────
    #
    # tasks.status: preenche NULLs existentes com 0 (todo) antes de adicionar
    # a constraint — garante que não há registros órfãos sem estado definido.
    change_column_default :tasks, :status, from: nil, to: 0
    change_column_null    :tasks, :status, false, 0

    # tasks.title: validação de presença já impede criação sem título via model,
    # mas o banco também deve reforçar a regra.
    change_column_null :tasks, :title, false

    # projects.name: idem — validação existe no model, o banco confirma.
    change_column_null :projects, :name, false

    # ── Índices para performance ───────────────────────────────────────────────
    #
    # Filtro por status (coluna Kanban) — evita full table scan ao exibir o board.
    add_index :tasks, :status, name: "index_tasks_on_status"

    # Ordenação por posição dentro de um projeto — scope :ordered usa position.
    add_index :tasks, :position, name: "index_tasks_on_position"

    # Índice composto para a query mais frequente da API:
    # tasks onde project_id = X e status = Y (board Kanban e filtros da API).
    add_index :tasks, [:project_id, :status],
              name: "index_tasks_on_project_id_and_status"
  end

  def down
    remove_index :tasks, name: "index_tasks_on_project_id_and_status"
    remove_index :tasks, name: "index_tasks_on_position"
    remove_index :tasks, name: "index_tasks_on_status"

    change_column_null :projects, :name, true
    change_column_null :tasks, :title, true
    change_column_null :tasks, :status, true
    change_column_default :tasks, :status, from: 0, to: nil
  end
end
