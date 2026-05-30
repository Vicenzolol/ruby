require "rails_helper"

# Request specs para as rotas web de Tasks — shallow nested em /projects/:id/tasks
RSpec.describe "Tasks (Web)", type: :request do
  let(:user)    { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task)    { create(:task, project: project) }

  def sign_in(user)
    post "/session", params: {
      email_address: user.email_address,
      password: "senha_segura123"
    }
  end

  describe "GET /projects/:project_id/tasks/new" do
    context "sem autenticação" do
      it "redireciona para o login" do
        get "/projects/#{project.id}/tasks/new"
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "autenticado" do
      before { sign_in(user) }

      it "retorna 200 com o formulário de criação" do
        get "/projects/#{project.id}/tasks/new"
        expect(response).to have_http_status(:ok)
      end
    end
  end


  describe "POST /projects/:project_id/tasks" do
    context "autenticado" do
      before { sign_in(user) }

      it "cria tarefa e redireciona para o board" do
        expect do
          post "/projects/#{project.id}/tasks",
               params: { task: { title: "Nova Tarefa", status: "todo" } }
        end.to change(Task, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end

      it "retorna 422 com título em branco" do
        post "/projects/#{project.id}/tasks",
             params: { task: { title: "", status: "todo" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    context "autenticado" do
      before { sign_in(user) }

      it "exclui a tarefa e redireciona para o board" do
        task
        expect do
          delete "/tasks/#{task.id}"
        end.to change(Task, :count).by(-1)

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end

