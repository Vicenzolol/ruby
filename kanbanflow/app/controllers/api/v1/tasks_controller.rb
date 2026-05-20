module Api
  module V1
    class TasksController < BaseController
      before_action :set_project, only: %i[index create]
      before_action :set_task,    only: %i[show update destroy]

      # GET /api/v1/projects/:project_id/tasks
      # Aceita ?status=todo|in_progress|done para filtrar
      def index
        tasks = @project.tasks.ordered
        tasks = tasks.by_status(params[:status]) if params[:status].present?
        render json: tasks.map { |t| task_json(t) }
      end

      # GET /api/v1/tasks/:id
      def show
        render json: task_json(@task)
      end

      # POST /api/v1/projects/:project_id/tasks
      def create
        task = @project.tasks.build(task_params)
        if task.save
          render json: task_json(task), status: :created
        else
          json_error(task.errors.full_messages)
        end
      end

      # PATCH /api/v1/tasks/:id
      def update
        if @task.update(task_params)
          render json: task_json(@task)
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

      def task_json(task)
        {
          id:          task.id,
          project_id:  task.project_id,
          title:       task.title,
          description: task.description,
          status:      task.status,
          position:    task.position,
          created_at:  task.created_at,
          updated_at:  task.updated_at
        }
      end
    end
  end
end
