# app/views/api/v1/projects/_project.json.jbuilder
# Partial reutilizada em index, show, create e update

json.id          project.id
json.name        project.name
json.description project.description
json.color       project.color
json.tasks_count project.tasks.size
json.created_at  project.created_at.iso8601
json.updated_at  project.updated_at.iso8601
