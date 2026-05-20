module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: %i[show update destroy]

      # GET /api/v1/projects
      def index
        projects = current_user.projects.recent.includes(:tasks)
        render json: projects.map { |p| project_json(p) }
      end

      # GET /api/v1/projects/:id
      def show
        render json: project_json(@project, include_tasks: true)
      end

      # POST /api/v1/projects
      def create
        project = current_user.projects.build(project_params)
        if project.save
          render json: project_json(project), status: :created
        else
          json_error(project.errors.full_messages)
        end
      end

      # PATCH /api/v1/projects/:id
      def update
        if @project.update(project_params)
          render json: project_json(@project)
        else
          json_error(@project.errors.full_messages)
        end
      end

      # DELETE /api/v1/projects/:id
      def destroy
        @project.destroy
        head :no_content
      end

      private

      def set_project
        @project = current_user.projects.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        json_error("Projeto não encontrado", status: :not_found)
      end

      def project_params
        params.require(:project).permit(:name, :description, :color)
      end

      def project_json(project, include_tasks: false)
        data = {
          id:          project.id,
          name:        project.name,
          description: project.description,
          color:       project.color,
          tasks_count: project.tasks.size,
          created_at:  project.created_at
        }
        if include_tasks
          data[:tasks] = project.tasks.ordered.map { |t| task_json(t) }
        end
        data
      end

      def task_json(task)
        {
          id:          task.id,
          title:       task.title,
          description: task.description,
          status:      task.status,
          position:    task.position,
          created_at:  task.created_at
        }
      end
    end
  end
end
