class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP, message: "deve ser um e-mail válido" },
                            uniqueness: { case_sensitive: false, message: "já está em uso" }
  validates :password, length: { minimum: 8, message: "deve ter pelo menos 8 caracteres" }, if: :password_digest_changed?

  before_create :generate_api_token

  def self.authenticate_by_token(token)
    find_by(api_token: token)
  end

  def regenerate_api_token!
    update!(api_token: generate_unique_token)
  end

  private

  def generate_api_token
    self.api_token = generate_unique_token
  end

  def generate_unique_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless User.exists?(api_token: token)
    end
  end
end
