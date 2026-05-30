class Task < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :project

  enum :status, { todo: 0, in_progress: 1, done: 2 }

  validates :title, presence: { message: "é obrigatório" },
                    length: { maximum: 200, message: "deve ter no máximo 200 caracteres" }

  scope :by_status, ->(s) { where(status: s) }
  scope :ordered,   -> { order(:position) }

  before_create :set_position

  # Turbo Streams: atualiza o board em tempo real para todos os usuários conectados
  after_create_commit  -> { broadcast_append_to project, target: "#{status}-tasks",
                              partial: "tasks/task", locals: { task: self } }
  after_update_commit  :broadcast_status_change
  after_destroy_commit -> { broadcast_remove_to project, target: dom_id(self) }

  private

  def set_position
    last = project.tasks.maximum(:position) || 0
    self.position = last + 1
  end

  def broadcast_status_change
    if saved_change_to_status?
      # Remove da coluna antiga
      broadcast_remove_to project, target: dom_id(self)
      # Adiciona na nova coluna
      broadcast_append_to project, target: "#{status}-tasks",
        partial: "tasks/task", locals: { task: self }
    else
      # Atualiza o card no lugar
      broadcast_replace_to project, target: dom_id(self),
        partial: "tasks/task", locals: { task: self }
    end
  end
end
