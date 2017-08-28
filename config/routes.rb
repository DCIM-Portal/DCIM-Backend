require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  get 'admin', to: 'admin#index'
  namespace :admin do
    resources :brute_lists, :path => 'bmc_scan_requests/bmc_credentials', except: [:edit, :new] do
      collection do
        get :datatable, to: 'brute_lists#datatable', klass: Admin::BruteListDatatable
      end
    end
    resources :zones, :path => 'datacenter_zones' , except: [:edit, :new] do
      collection do
        post :foreman_remove
        post :foreman_add
        delete :multi_delete
        post :multi_create
        get :datatable, to: 'datatable', klass: Admin::ZoneDatatable
      end
      member do
        get :bmc_hosts_datatable, to: 'zones#datatable', klass: Admin::ZoneDetailsDatatable
      end
    end
    get :api_zone, :controller => :zones
    resources :bmc_hosts, :path => 'bmc_hosts' do
      collection do
        get :datatable, to: 'bmc_hosts#datatable', klass: Admin::BmcHostDatatable
      end
    end
    resources :bmc_scan_requests, :path => 'bmc_scan_requests', except: [:edit, :new] do
      collection do
        get :datatable, to: 'bmc_scan_requests#datatable', klass: Admin::BmcScanRequestDatatable
      end
      member do
        get :bmc_hosts_datatable, to: 'bmc_scan_requests#datatable', klass: Admin::BmcScanRequestDetailsDatatable
      end
    end
    get :api_bmc_scan_request, :controller => :bmc_scan_requests
  end
  resources :systems
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
