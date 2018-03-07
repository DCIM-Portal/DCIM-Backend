require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Rails.application.routes.draw do
  apipie
  get '/', to: 'home#index'

  concern :api_base do
    get '/', to: 'home#index'
    get '/status', to: 'home#status'
    post '/auth/user_token', to: 'user_token#create'
    resources :zones do
      collection do
        get 'diff', to: 'zones#diff'
        post 'diff/resolve', to: 'zones#diff_resolve'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      concerns :api_base
    end

    match 'v1/*path', via: %i[all], to: proc { [404, {}, ['']] }
    match 'v:api_version/*path', via: %i[all], to: redirect('/api/v1/%{path}')
    match '*path', via: %i[all], to: redirect('/api/v1/%{path}')
  end

  get 'admin', to: 'admin#index'
  # /admin
  namespace :admin do
    # ./zones
    # ./zone/{id}
    resources :zones, path: 'zones', except: %i[edit new] do
      # resources :enclosure_racks, shallow: true, path: 'racks'
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
    # ./racks/{id}
    resources :enclosure_racks, path: 'racks', except: %i[edit new] do
      collection do
        get :datatable, to: 'enclosure_racks#datatable', klass: Admin::EnclosureRackDatatable
      end
    end
    # ./enclosure/{id}
    # ./device/{id}
    # ./bmc_hosts/credentials
    # ./bmc_hosts/credential/{id}
    resources :brute_lists, path: 'bmc_hosts/credentials', except: %i[edit new] do
      collection do
        get :datatable, to: 'brute_lists#datatable', klass: Admin::BruteListDatatable
      end
    end
    # ./bmc_hosts/scans
    # ./bmc_hosts/scan/{id}
    resources :bmc_scan_requests, path: 'bmc_hosts/scans', except: %i[edit new] do
      collection do
        get :datatable, to: 'bmc_scan_requests#datatable', klass: Admin::BmcScanRequestDatatable
      end
      member do
        get :bmc_hosts_datatable, to: 'bmc_scan_requests#datatable', klass: Admin::BmcScanRequestDetailsDatatable
      end
    end
    # ./bmc_hosts/onboards
    # ./bmc_hosts/onboard/{id}
    resources :onboard_requests, path: 'bmc_hosts/onboards', except: %i[edit new] do
      collection do
        get :datatable, to: 'onboard_requests#datatable', klass: Admin::OnboardRequestDatatable
        post :new_modal
      end
      member do
        get :bmc_hosts_datatable, to: 'onboard_requests#datatable', klass: Admin::OnboardRequestDetailsDatatable
      end
    end
    # ./bmc_hosts
    # ./bmc_host/{id}
    resources :bmc_hosts, path: 'bmc_hosts' do
      collection do
        post :multi_action
        post :new_modal
        get :datatable, to: 'bmc_hosts#datatable', klass: Admin::BmcHostDatatable
      end
    end
    # ./systems
    # ./system/{id}
    # ./visual_dc/zone/{id}
    get '/visual_dc', to: 'visual_dc#index'
    get '/visual_dc/zone/:zone_id', as: 'visual_dc_zone', to: 'visual_dc#show'
    # ./visual_dc/rack/{id}
    # ./visual_dc/enclosure/{id}

    # ./datatable
    get '/datatable/*route', to: 'datatables#show', as: 'datatable'

    get :check_foreman_locations_synced, controller: :zones
    get :check_foreman_reachable, controller: :bmc_scan_requests
  end

  resources :systems

  mount Sidekiq::Web => '/sidekiq'
  mount ActionCable.server, at: '/cable'
end
