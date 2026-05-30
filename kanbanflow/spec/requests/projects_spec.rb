require "rails_helper"

# Request specs para a interface web (não a API) — rota: /projects
# Cobertura: redirect para unauthenticated + acesso autenticado
RSpec.describe "Projects (Web)", type: :request do
  let(:user)    { create(:user) }
  let(:project) { create(:project, user: user) }

  # Helper: simula login via session controller
  def sign_in(user)
    post "/session", params: {
      email_address: user.email_address,
      password: "senha_segura123"
    }
  end

  describe "GET /projects" do
    context "sem autenticação" do
      it "redireciona para o login" do
        get "/projects"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "autenticado" do
      before { sign_in(user) }

      it "retorna 200 com a lista de projetos" do
        project
        get "/projects"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /projects/new" do
    context "sem autenticação" do
      it "redireciona para o login" do
        get "/projects/new"
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "autenticado" do
      before { sign_in(user) }

      it "retorna 200 com o formulário de criação" do
        get "/projects/new"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /projects/:id" do
    context "sem autenticação" do
      it "redireciona para o login" do
        get "/projects/#{project.id}"
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "autenticado" do
      before { sign_in(user) }

      it "retorna 200 com o board do projeto" do
        get "/projects/#{project.id}"
        expect(response).to have_http_status(:ok)
      end

      it "retorna 404 para projeto de outro usuário" do
        outro = create(:project)
        get "/projects/#{outro.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /projects/:id/edit" do
    context "autenticado" do
      before { sign_in(user) }

      it "retorna 200 com o formulário de edição" do
        get "/projects/#{project.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /projects" do
    context "autenticado" do
      before { sign_in(user) }

      it "cria projeto e redireciona para o board" do
        expect do
          post "/projects", params: { project: { name: "Novo Projeto", color: Project::COLORS.first } }
        end.to change(Project, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end

      it "retorna 422 com parâmetros inválidos" do
        post "/projects", params: { project: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /projects/:id" do
    context "autenticado" do
      before { sign_in(user) }

      it "exclui o projeto e redireciona" do
        project
        expect do
          delete "/projects/#{project.id}"
        end.to change(Project, :count).by(-1)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
