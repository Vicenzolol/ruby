require "rails_helper"

RSpec.describe Project, type: :model do
  subject(:project) { build(:project) }

  # ─── Associations ────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
  end

  # ─── Validations ────────────────────────────────────────────
  describe "validations" do
    describe "#name" do
      it "é obrigatório" do
        project.name = ""
        expect(project).not_to be_valid
        expect(project.errors[:name]).to include("é obrigatório")
      end

      it "aceita nome válido" do
        project.name = "Meu Projeto"
        expect(project).to be_valid
      end

      it "rejeita nome com mais de 100 caracteres" do
        project.name = "A" * 101
        expect(project).not_to be_valid
        expect(project.errors[:name]).to include("deve ter no máximo 100 caracteres")
      end

      it "aceita nome com exatamente 100 caracteres" do
        project.name = "A" * 100
        expect(project).to be_valid
      end
    end

    describe "#color" do
      it "aceita uma cor válida da paleta" do
        project.color = Project::COLORS.first
        expect(project).to be_valid
      end

      it "rejeita cor fora da paleta" do
        project.color = "#000000"
        expect(project).not_to be_valid
        expect(project.errors[:color]).to include("deve ser uma cor válida")
      end

      it "aceita color em branco (campo opcional)" do
        project.color = ""
        expect(project).to be_valid
      end

      it "aceita color nil" do
        project.color = nil
        expect(project).to be_valid
      end
    end
  end

  # ─── Scopes ─────────────────────────────────────────────────
  describe ".recent" do
    it "retorna projetos em ordem decrescente de criação" do
      user  = create(:user)
      antigo = create(:project, user: user, created_at: 2.days.ago)
      recente = create(:project, user: user, created_at: 1.day.ago)

      expect(Project.recent).to eq([recente, antigo])
    end
  end

  # ─── Constantes ──────────────────────────────────────────────
  describe "COLORS" do
    it "contém exatamente 8 cores hexadecimais" do
      expect(Project::COLORS.size).to eq(8)
      expect(Project::COLORS).to all(match(/\A#[0-9a-f]{6}\z/))
    end
  end

  # ─── Dependent destroy ──────────────────────────────────────
  describe "dependent destroy" do
    it "apaga as tasks associadas ao deletar o projeto" do
      project.save!
      create(:task, project: project)
      expect { project.destroy }.to change(Task, :count).by(-1)
    end
  end
end

