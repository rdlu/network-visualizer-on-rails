MomRails::Application.routes.draw do
  get 'route_reload' => 'welcome#route_reload'

  match 'reports' => 'reports#index', :as => 'reports'
  get 'reports/index', :as => 'index_reports'
  match 'reports/graph/:source_id/:destination_id/:metric_id' => 'reports#graph', :via => [:get]
  post 'reports/graph', :as =>'graph_reports'
  post 'reports/eaq_graph', :as =>'eaq_graph_reports'
  post 'kpi/show' => 'kpi#show', :as => 'show_kpi'
  post 'reports/csv'

  get 'dns' => 'dns#index', :as => 'dns'
  get 'dns' => 'dns#index', :as => 'dns_index'
  get 'dns/new' => 'dns#new', :as => 'new_dns'
  get 'dns/:id' => 'dns#show', :as => 'dns'
  get 'dns/:id' => 'dns#show', :as => 'show_dns'
  get 'dns/edit/:id' => 'dns#edit', :as => 'edit_dns'
  post 'dns' => 'dns#create', :as => 'create_dns'
  put 'dns/:id' => 'dns#update', :as => 'dns'
  delete 'dns/:id' => 'dns#destroy', :as => 'dns'
  delete 'dns' => 'dns#destroy', :as => 'dns'

  resources :metrics
  resources :tests
  resources :schedules
 
  resources :probes do
    member do
      get 'destinations'
      get 'sources'

    end
  end

  post 'probes/load_location',:as=> 'probes_load_location'

  match 'probes/:id/metrics/:source_id' => 'probes#metrics', :via => [:get]
  match 'probes/:id/thresholds/:source_id' => 'probes#thresholds', :via => [:get]

  resources :metrics
  resources :profiles
  resources :connection_profiles do
    resources :plans
  end
  resources :thresholds
  resources :plans

  devise_for :users #, :controllers => { :registrations => "registrations" }
  resources :users do
    get :active
  end
  as :user do
    put :update_password, :controller => :users
  end

  get 'users/sign_in'

  get 'welcome/index'

  # /welcome/status/1/2.json
  match 'welcome/status/:source/:destination' => 'welcome#status', :via => [:get]

  # /welcome/stats.json
  get 'welcome/stats'

  #match collect
  #"/collect/id/3/throughput_http/34504848.484848/34504848.484848/34504848.484848/22143940.658321/22143940.658321/22143940.658321/1362070592/0.0"
  match 'collect/id' => 'results#index'
  match 'collect/id/:destination_id/:metric_name/:dsmax/:dsmin/:dsavg/:sdmax/:sdmin/:sdavg/:timestamp/:uuid' => 'results#create',
        :via => [:get],
        :as => 'results_create',
        :constraints => { :destination_id => /\d+/,
                          :metric_name => /[a-z_]+/,
                          :dsmax => /[-]*[0-9]+[.]*[0-9]+/,
                          :dsmin => /[-]*[0-9]+[.]*[0-9]+/,
                          :dsavg => /[-]*[0-9]+[.]*[0-9]+/,
                          :sdmax => /[-]*[0-9]+[.]*[0-9]+/,
                          :sdmin => /[-]*[0-9]+[.]*[0-9]+/,
                          :sdavg => /[-]*[0-9]+[.]*[0-9]+/,
                          :timestamp => /\d+/,
                          :uuid => /[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+/
        }

  #/collect/id/2/kpis/3567/SonyEricsson/R800i/-/-/-101/-/-/-/0/4/1551/1361215988/db14c4a2-1629-4f2e-9fc5-361d3fec4b74
  #/collect/id/3/kpis/-/-/-/-/-/-/-/0/143.54.85.34/1500/2/-/1362063316/44167d08-b2ea-4341-831e-50f7b8b7a4c8
  match 'collect/id/:destination_id/kpis/:cell_id/:brand/:model/:conn_type/:conn_tech/:signal/:error_rate/:change_of_ips/:route/:mtu/:dns_latency/:lac/:timestamp/:uuid' => 'kpi#create',
        :via => [:get],
        :as => 'kpi_create',
        :constraints => { :destination_id => /\d+/,
                          :cell_id => /[0-9\-]+/,
                          :brand => /.+/,
                          :model => /.+/,
                          :conn_type => /[A-Za-z\-]+/,
                          :conn_tech => /[A-Za-z\-]+/,
                          :signal => /[>|<]*[0-9.\- ]+|Desconhecido|unknown/,
                          :error_rate => /[>|<]*[0-9.\- ]+|Desconhecido|unknown'/,
                          :change_of_ips => /[0-9\-]+/,
                          :route => /.+/,
                          :mtu => /[0-9\-]+|Desconhecido/,
                          :dns_latency => /[%3C]*[0-9.\- ><]+|Desconhecido/,
                          :lac => /[0-9\-]+/,
                          :timestamp => /\d+/,
                          :uuid => /[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+/
        }

  match 'schedules/unused_profiles_form/:source_id/:destination_id' => 'schedules#unused_profiles_form',
        :constraints => {
            :source_id => /\d+/,
            :destination_id => /\d+/,
        }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#login'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
