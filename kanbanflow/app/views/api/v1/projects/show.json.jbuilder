# app/views/api/v1/projects/show.json.jbuilder
# GET /api/v1/projects/:id  — inclui tasks aninhadas
# Também usado por create (status 201) e update (status 200)

json.partial! "api/v1/projects/project", project: @project

json.tasks do
  json.array! @project.tasks.ordered do |task|
    json.partial! "api/v1/tasks/task", task: task
  end
end
