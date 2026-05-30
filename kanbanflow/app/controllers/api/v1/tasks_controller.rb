module Api
  module V1
    class TasksController < BaseController
      before_action :set_project, only: %i[index create]
      before_action :set_task,    only: %i[show update destroy]

      # GET /api/v1/projects/:project_id/tasks?status=todo&page=1&per_page=20
      # Aceita ?status=todo|in_progress|done para filtrar por coluna Kanban
      def index
        scope = @project.tasks.ordered
        scope = scope.by_status(params[:status]) if params[:status].present?
        @pagy, @tasks = pagy(scope, limit: params.fetch(:per_page, 20).to_i)
        # Renderiza app/views/api/v1/tasks/index.json.jbuilder
      end

      # GET /api/v1/tasks/:id
      def show
        # Renderiza app/views/api/v1/tasks/show.json.jbuilder
      end

      # POST /api/v1/projects/:project_id/tasks
      def create
        @task = @project.tasks.build(task_params)
        if @task.save
          render :show, status: :created
        else
          json_error(@task.errors.full_messages)
        end
      end

      # PATCH /api/v1/tasks/:id
      def update
        if @task.update(task_params)
          render :show
        else
          json_error(@task.errors.full_messages)
        end
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        @task.destroy
        head :no_content
      end

      private

      def set_project
        @project = current_user.projects.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        json_error("Projeto não encontrado", status: :not_found)
      end

      def set_task
        @task = Task.joins(:project).where(projects: { user_id: current_user.id }).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        json_error("Tarefa não encontrada", status: :not_found)
      end

      def task_params
        params.require(:task).permit(:title, :description, :status)
      end
    end
  end
end
