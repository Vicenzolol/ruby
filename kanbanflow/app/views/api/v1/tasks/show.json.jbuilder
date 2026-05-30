# app/views/api/v1/tasks/show.json.jbuilder
# GET /api/v1/tasks/:id  — e também create/update (via render :show)

json.partial! "api/v1/tasks/task", task: @task
