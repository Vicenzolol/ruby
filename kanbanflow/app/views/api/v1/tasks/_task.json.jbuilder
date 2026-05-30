# app/views/api/v1/tasks/_task.json.jbuilder
# Partial reutilizada em index, show, create e update

json.id          task.id
json.project_id  task.project_id
json.title       task.title
json.description task.description
json.status      task.status
json.position    task.position
json.created_at  task.created_at.iso8601
json.updated_at  task.updated_at.iso8601
