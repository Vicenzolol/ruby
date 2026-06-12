Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token

  resources :projects do
    resources :tasks, shallow: true
    patch :update_task_status, on: :member
  end

  namespace :api do
    namespace :v1 do
      resources :projects, only: %i[index show create update destroy] do
        resources :tasks, only: %i[index create], shallow: false
      end
      resources :tasks, only: %i[show update destroy]
      get "me", to: "users#me"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "projects#index"
end
