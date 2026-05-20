class Task < ApplicationRecord
  belongs_to :project

  enum :status, { todo: 0, in_progress: 1, done: 2 }

  validates :title, presence: { message: "é obrigatório" },
                    length: { maximum: 200, message: "deve ter no máximo 200 caracteres" }

  scope :by_status, ->(s) { where(status: s) }
  scope :ordered,   -> { order(:position) }

  before_create :set_position

  private

  def set_position
    last = project.tasks.maximum(:position) || 0
    self.position = last + 1
  end
end
