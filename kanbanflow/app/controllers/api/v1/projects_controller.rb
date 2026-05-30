module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: %i[show update destroy]

      # GET /api/v1/projects?page=1&per_page=20
      # Resposta: { data: [...], meta: { current_page:, total_pages:, total_count:, per_page: } }
      def index
        @pagy, @projects = pagy(current_user.projects.recent.includes(:tasks),
                                limit: params.fetch(:per_page, 20).to_i)
        # Renderiza app/views/api/v1/projects/index.json.jbuilder
      end

      # GET /api/v1/projects/:id
      # Resposta: projeto com array de tasks
      def show
        # Renderiza app/views/api/v1/projects/show.json.jbuilder
      end

      # POST /api/v1/projects
      def create
        @project = current_user.projects.build(project_params)
        if @project.save
          render :show, status: :created
        else
          json_error(@project.errors.full_messages)
        end
      end

      # PATCH /api/v1/projects/:id
      def update
        if @project.update(project_params)
          render :show
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
    end
  end
end
