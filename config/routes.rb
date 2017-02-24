require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  resources :ilo_scan_jobs
  post 'ilo_scan_jobs/:id/provision', to: 'ilo_scan_jobs#provision', as: 'provision'
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
