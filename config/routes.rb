require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  resources :systems
  resources :brute_lists, :path => 'bmc_scan_requests/bmc_credentials', except: [:edit, :new]
  resources :zones, :path => 'datacenter_zones' , except: [:edit, :new] do
    collection do
      post :foreman_remove
      post :foreman_add
      delete :multi_delete
      post :multi_create
    end
  end
  get :api_zone, :controller => :zones
  get :api_bmc_scan_request, :controller => :bmc_scan_requests
  resources :bmc_hosts
  resources :bmc_scan_requests, except: [:edit, :new]
  resources :admin
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
