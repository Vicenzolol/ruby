# app/views/api/v1/projects/index.json.jbuilder
# GET /api/v1/projects?page=1&per_page=20
# Retorna lista paginada com metadados

json.data do
  json.array! @projects do |project|
    json.partial! "api/v1/projects/project", project: project
  end
end

json.meta do
  json.current_page @pagy.page
  json.total_pages  @pagy.last
  json.total_count  @pagy.count
  json.per_page     @pagy.limit
end
