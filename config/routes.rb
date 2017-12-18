require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  get 'admin', to: 'admin#index'
  namespace :admin do
    resources :brute_lists, path: 'bmc_scan_requests/bmc_credentials', except: %i[edit new] do
      collection do
        get :datatable, to: 'brute_lists#datatable', klass: Admin::BruteListDatatable
      end
    end
    resources :onboard_requests, path: 'bmc_hosts/onboard_requests', except: %i[edit new] do
      collection do
        get :datatable, to: 'onboard_requests#datatable', klass: Admin::OnboardRequestDatatable
        post :new_modal
      end
      member do
        get :bmc_hosts_datatable, to: 'onboard_requests#datatable', klass: Admin::OnboardRequestDetailsDatatable
      end
    end
    resources :zones, path: 'datacenter_zones', except: %i[edit new] do
      resources :enclosure_racks, shallow: true, path: 'racks'
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
    get :check_foreman_locations_synced, controller: :zones
    resources :bmc_hosts, path: 'bmc_hosts' do
      collection do
        post :multi_action
        post :new_modal
        get :datatable, to: 'bmc_hosts#datatable', klass: Admin::BmcHostDatatable
      end
    end
    resources :bmc_scan_requests, path: 'bmc_scan_requests', except: %i[edit new] do
      collection do
        get :datatable, to: 'bmc_scan_requests#datatable', klass: Admin::BmcScanRequestDatatable
      end
      member do
        get :bmc_hosts_datatable, to: 'bmc_scan_requests#datatable', klass: Admin::BmcScanRequestDetailsDatatable
      end
    end
    get :check_foreman_reachable, controller: :bmc_scan_requests
  end
  resources :systems
  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
