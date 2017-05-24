require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  resources :brute_lists, :path => 'bmc_scan_jobs/bmc_credentials'
  resources :zones, :path => 'datacenter_zones'
  resources :bmc_hosts
  resources :bmc_scan_jobs
  post 'ilo_scan_jobs/:id/provision', to: 'ilo_scan_jobs#provision', as: 'provision'
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
