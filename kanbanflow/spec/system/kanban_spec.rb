require "rails_helper"

# ─── Testes de Sistema (Capybara + Headless Chrome) ────────────────────────────
# Pré-requisito: Google Chrome instalado no WSL.
#   sudo apt-get install -y google-chrome-stable
# Para rodar apenas estes specs:
#   bundle exec rspec spec/system/ --format documentation
# ──────────────────────────────────────────────────────────────────────────────

RSpec.describe "Fluxo Kanban", type: :system do
  before do
    driven_by(:headless_chrome)
  end

  let(:user)     { create(:user, email_address: "usuario@test.com", password: "senha_segura123") }
  let(:project)  { create(:project, user: user, name: "Meu Projeto Teste") }

  # ─── Helper de login ──────────────────────────────────────────────────────
  def fazer_login(email: user.email_address, senha: "senha_segura123")
    visit root_path
    fill_in "Email address", with: email
    fill_in "Password",      with: senha
    click_button "Sign in"
  end

  # ─── Cadastro ─────────────────────────────────────────────────────────────
  describe "Cadastro de novo usuário" do
    it "usuário se cadastra com sucesso e é redirecionado" do
      visit new_registration_path
      fill_in "Email address", with: "novo@example.com"
      fill_in "Password",      with: "minha_senha_123"
      fill_in "Password confirmation", with: "minha_senha_123"
      click_button "Create account"

      # Após cadastro é redirecionado para a lista de projetos
      expect(page).to have_current_path(projects_path)
    end
  end

  # ─── Login / Logout ───────────────────────────────────────────────────────
  describe "Autenticação" do
    it "login com credenciais válidas exibe lista de projetos" do
      user # força criação
      fazer_login
      expect(page).to have_current_path(projects_path)
    end

    it "login com senha errada exibe mensagem de erro" do
      user # força criação
      fazer_login(senha: "senha_errada")
      expect(page).to have_current_path(new_session_path)
    end

    it "logout encerra a sessão e redireciona ao login" do
      user
      fazer_login
      click_button "Sign out"
      expect(page).to have_current_path(new_session_path)
    end
  end

  # ─── Projetos ─────────────────────────────────────────────────────────────
  describe "Gestão de Projetos" do
    before { fazer_login }

    it "cria um novo projeto e exibe na lista" do
      click_link "New Project"
      fill_in "Name", with: "Projeto Sistema"
      click_button "Create Project"

      expect(page).to have_content("Projeto Sistema")
    end

    it "exibe os projetos do usuário na lista" do
      project # força criação
      visit projects_path
      expect(page).to have_content("Meu Projeto Teste")
    end

    it "edita o nome de um projeto" do
      project
      visit projects_path
      click_link "Meu Projeto Teste"
      click_link "Edit"
      fill_in "Name", with: "Projeto Editado"
      click_button "Update Project"
      expect(page).to have_content("Projeto Editado")
    end
  end

  # ─── Tarefas (Board Kanban) ────────────────────────────────────────────────
  describe "Board Kanban — gestão de tarefas" do
    before do
      project # força criação
      fazer_login
      visit project_path(project)
    end

    it "cria uma nova tarefa na coluna Todo" do
      within "#todo-column" do
        click_link "Add task"
        fill_in "Title", with: "Minha tarefa nova"
        click_button "Create Task"
      end
      expect(page).to have_content("Minha tarefa nova")
    end

    it "exibe as colunas do board" do
      expect(page).to have_css("[id*='todo']")
      expect(page).to have_css("[id*='in_progress']")
      expect(page).to have_css("[id*='done']")
    end
  end
end
