# app/views/api/v1/tasks/index.json.jbuilder
# GET /api/v1/projects/:project_id/tasks?page=1&per_page=20&status=todo
# Retorna lista paginada com metadados

json.data do
  json.array! @tasks do |task|
    json.partial! "api/v1/tasks/task", task: task
  end
end

json.meta do
  json.current_page @pagy.page
  json.total_pages  @pagy.last
  json.total_count  @pagy.count
  json.per_page     @pagy.limit
end
