require "rails_helper"

RSpec.describe User, type: :model do
  # ─── Factories ───────────────────────────────────────────────────────────────
  subject(:user) { build(:user) }

  # ─── Associations ────────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:projects).dependent(:destroy) }
  end

  # ─── Validations ─────────────────────────────────────────────────────────────
  describe "validations" do
    describe "#email_address" do
      it "é obrigatório" do
        user.email_address = ""
        expect(user).not_to be_valid
        expect(user.errors[:email_address]).to be_present
      end

      it "aceita um e-mail válido" do
        user.email_address = "joao@example.com"
        expect(user).to be_valid
      end

      it "rejeita formato inválido" do
        user.email_address = "nao_e_um_email"
        expect(user).not_to be_valid
        expect(user.errors[:email_address]).to include("deve ser um e-mail válido")
      end

      it "rejeita e-mail duplicado (case-insensitive)" do
        create(:user, email_address: "joao@example.com")
        user.email_address = "JOAO@example.com"
        expect(user).not_to be_valid
        expect(user.errors[:email_address]).to include("já está em uso")
      end

      it "normaliza para minúsculas sem espaços" do
        user.email_address = "  Maria@EXAMPLE.COM  "
        user.save!
        expect(user.email_address).to eq("maria@example.com")
      end
    end

    describe "#password" do
      it "rejeita senha com menos de 8 caracteres" do
        user.password = "curta"
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("deve ter pelo menos 8 caracteres")
      end

      it "aceita senha com 8 ou mais caracteres" do
        user.password = "senha_ok_123"
        expect(user).to be_valid
      end
    end
  end

  # ─── API Token ───────────────────────────────────────────────────────────────
  describe "api_token" do
    it "é gerado automaticamente ao criar o usuário" do
      user.save!
      expect(user.api_token).to be_present
    end

    it "tem pelo menos 32 caracteres (urlsafe_base64(32) → 43 chars)" do
      user.save!
      expect(user.api_token.length).to be >= 32
    end

    it "é único entre usuários diferentes" do
      u1 = create(:user)
      u2 = create(:user)
      expect(u1.api_token).not_to eq(u2.api_token)
    end

    describe ".authenticate_by_token" do
      it "retorna o usuário quando o token é válido" do
        user.save!
        expect(User.authenticate_by_token(user.api_token)).to eq(user)
      end

      it "retorna nil quando o token é inválido" do
        expect(User.authenticate_by_token("token_inexistente")).to be_nil
      end

      it "retorna nil quando token é nil" do
        expect(User.authenticate_by_token(nil)).to be_nil
      end
    end

    describe "#regenerate_api_token!" do
      it "gera um novo token diferente do anterior" do
        user.save!
        token_antigo = user.api_token
        user.regenerate_api_token!
        expect(user.api_token).not_to eq(token_antigo)
      end

      it "persiste o novo token no banco" do
        user.save!
        user.regenerate_api_token!
        expect(User.find(user.id).api_token).to eq(user.api_token)
      end
    end
  end
end

