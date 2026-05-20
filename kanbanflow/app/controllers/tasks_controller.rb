class TasksController < ApplicationController
  before_action :set_project, only: %i[new create]
  before_action :set_task, only: %i[show edit update destroy]

  def show; end

  def new
    @task = @project.tasks.build
  end

  def create
    @task = @project.tasks.build(task_params)
    if @task.save
      redirect_to @project, notice: "Tarefa criada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to @task.project, notice: "Tarefa atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    project = @task.project
    @task.destroy
    redirect_to project, notice: "Tarefa excluída com sucesso."
  end

  private

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def set_task
    @task = Task.joins(:project).where(projects: { user_id: Current.user.id }).find(params[:id])
  end

  def task_params
    params.expect(task: [ :title, :description, :status ])
  end
end
