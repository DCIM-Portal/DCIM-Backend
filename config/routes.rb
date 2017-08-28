require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  resources :systems
  resources :brute_lists, :path => 'admin/bmc_scan_requests/bmc_credentials', except: [:edit, :new] do
    collection do
      get :datatable, to: 'application#datatable', klass: BruteListDatatable
    end
  end
  resources :zones, :path => 'admin/datacenter_zones', except: [:edit, :new] do
    collection do
      post :foreman_remove
      post :foreman_add
      delete :multi_delete
      post :multi_create
      get :datatable, to: 'application#datatable', klass: ZoneDatatable
    end
    member do
      get :bmc_hosts_datatable, to: 'application#datatable', klass: ZoneDetailsDatatable
    end
  end
  get :api_zone, :controller => :zones
  get :api_bmc_scan_request, :controller => :bmc_scan_requests
  resources :bmc_hosts, :path => 'admin/bmc_hosts', except: [:edit, :new] do
    collection do
      post :onboard_modal
      get :onboard_modal
      get :datatable, to: 'application#datatable', klass: BmcHostDatatable
    end
  end
  resources :bmc_scan_requests, :path => 'admin/bmc_scan_requests', except: [:edit, :new] do
    collection do
      get :datatable, to: 'application#datatable', klass: BmcScanRequestDatatable
    end
    member do
      get :bmc_hosts_datatable, to: 'application#datatable', klass: BmcScanRequestDetailsDatatable
    end
  end
  resources :admin
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
