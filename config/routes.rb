require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  resources :ilo_scan_jobs
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
