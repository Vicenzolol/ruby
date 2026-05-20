class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP, message: "deve ser um e-mail válido" },
                            uniqueness: { case_sensitive: false, message: "já está em uso" }
  validates :password, length: { minimum: 8, message: "deve ter pelo menos 8 caracteres" }, if: :password_digest_changed?
end
