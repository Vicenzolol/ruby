Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token

  resources :projects do
    resources :tasks, shallow: true
    patch :update_task_status, on: :member
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"
end
