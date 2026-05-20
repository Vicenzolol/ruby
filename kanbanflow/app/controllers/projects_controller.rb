class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy update_task_status]

  def index
    @projects = Current.user.projects.recent
  end

  def show
    @tasks_by_status = {
      todo:        @project.tasks.by_status(:todo).ordered,
      in_progress: @project.tasks.by_status(:in_progress).ordered,
      done:        @project.tasks.by_status(:done).ordered
    }
    @new_task = @project.tasks.build
  end

  def new
    @project = Current.user.projects.build
  end

  def create
    @project = Current.user.projects.build(project_params)
    if @project.save
      redirect_to @project, notice: "Projeto criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Projeto atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Projeto excluído com sucesso."
  end

  # PATCH /projects/:id/update_task_status — chamado pelo Stimulus drag-drop
  def update_task_status
    task = @project.tasks.find(params[:task_id])
    task.update!(status: params[:status])
    head :ok
  rescue ActiveRecord::RecordNotFound, ArgumentError
    head :unprocessable_entity
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:id])
  end

  def project_params
    params.expect(project: [ :name, :description, :color ])
  end
end
