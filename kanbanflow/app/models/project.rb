class Project < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  COLORS = %w[#ef4444 #f97316 #eab308 #22c55e #3b82f6 #8b5cf6 #ec4899 #6b7280].freeze

  validates :name, presence: { message: "é obrigatório" },
                   length: { maximum: 100, message: "deve ter no máximo 100 caracteres" }
  validates :color, inclusion: { in: COLORS, message: "deve ser uma cor válida" }, allow_blank: true

  scope :recent, -> { order(created_at: :desc) }
end
