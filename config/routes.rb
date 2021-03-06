MomRails::Application.routes.draw do
  resources :sites


  resources :nameservers


  get 'route_reload' => 'welcome#route_reload'

  match 'reports' => 'reports#index', :as => 'reports'
  get 'reports/index', :as => 'index_reports'
  match 'reports/graph/:source_id/:destination_id/:metric_id' => 'reports#graph', :via => [:get]
  post 'reports/graph', :as =>'graph_reports'
  post 'reports/dygraphs_bruto', :as =>'dygraphs_bruto_reports'
  post 'reports/highcharts_bruto', :as =>'highcharts_bruto_reports'
  post 'reports/eaq_graph', :as =>'eaq_graph_reports'
  post 'reports/eaq_compliance_graph', :as =>'eaq_compliance_graph_reports'
  post 'reports/eaq_table', :as =>'eaq_table_reports'
  post 'reports/detail_eaq_table', :as =>'detail_eaq_table_reports'
  post 'reports/eaq2_table', :as => 'eaq2_table_reports'
  #get 'reports/eaq2_table', :as => 'eaq2_table_reports'
  post 'reports/detail_eaq2_table', :as=> 'detail_eaq2_table_reports'
  post 'reports/detail_speed_type_eaq2_table', :as => 'detail_speed_type_eaq2_table_reports'
  post 'reports/detail_probe_eaq2_table', :as => 'detail_probe_eaq2_table_reports'
  post 'kpi/show' => 'kpi#show', :as => 'show_kpi'
  match 'reports/csv_bruto/:filename' => 'reports#csv_bruto', :as => 'reports_csv_bruto', :via => [:get]
  match 'reports/csv_diario/:filename' => 'reports#csv_diario', :as => 'reports_csv_diario', :via => [:get]
  match 'reports/csv_mensal/:filename' => 'reports#csv_mensal', :as => 'reports_csv_mensal', :via => [:get]
  match 'reports/xls_bruto/:filename' => 'reports#xls_bruto', :as => 'reports_xls_bruto', :via => [:get]
  match 'reports/xls_diario/:filename' => 'reports#xls_diario', :as => 'reports_xls_diario', :via => [:get]
  match 'reports/xls_mensal/:filename' => 'reports#xls_mensal', :as => 'reports_xls_mensal', :via => [:get]
  post 'reports/send' => 'reports#send_report', :as => 'send_reports'
  match 'reports/performance/:filename' => 'reports#performance', :as => 'reports_performance_export', :via => [:get]
  post 'reports/performance', :as => 'performance_reports'
  post 'reports/smartrate', :as => 'smartrate_reports'
  post 'reports/pacman', :as => 'pacman_reports'
  post 'reports/pacman_details', :as => 'pacman_details_reports'
  post 'reports/pacman_activity', :as => 'pacman_activity_reports'
  post 'reports/pacman_service_activity', :as => 'pacman_service_activity_reports'
  post 'reports/pacman_service_activity_details', :as => 'pacman_service_activity_details_reports'
  resources :metrics
  resources :tests
  resources :schedules
  get 'schedules/win/schedule' => 'schedules#win', :as => 'windows_schedules'
  post 'schedules/private_schedule' => 'schedules#private_schedule', :as => 'private_schedules'
  post 'schedules/private_agt_index' => 'schedules#private_agt_index', :as => 'private_agt_indexes'
  resources :probes do
    member do
      get 'destinations'
      get 'sources'

    end
  end

  post 'probes/load_location',:as=> 'probes_load_location'
  post 'probes/filter_uf', :as => 'probes_filter_uf'
  post 'probes/filter_destination', :as => 'probes_filter_destination'
  post 'probes/find_cns_by_state', :as => 'probes_find_cns_by_state'

  match 'probes/:id/metrics/:source_id' => 'probes#metrics', :via => [:get]
  match 'probes/:id/thresholds/:source_id' => 'probes#thresholds', :via => [:get]

  resources :metrics
  resources :process
  resources :profiles
  resources :dns_profiles
  resources :url_profiles
  resources :raw_xml_profiles
  resources :http_profiles

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

  match 'welcome/probe_list/:type' => 'welcome#probe_list', :via => [:get], :as => 'welcome_probe_list'
  get 'welcome/probe_list'

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
  #/collect/id/55/kpis/4728/huawei/E226/Automatica/UMTS/-114/<0,2/2/Desconhecido-10.58.60.180-200.220.252.125-200.220.254.124-200.220.254.8/1500/1850/4169/1369252819/bd3c47fa-ce19-4a5d-8505-36921744229b
  match 'collect/id/:destination_id/kpis/:cell_id/:brand/:model/:conn_type/:conn_tech/:signal/:error_rate/:change_of_ips/:route/:mtu/:dns_latency/:lac/:timestamp/:uuid' => 'kpi#create',
        :via => [:get],
        :as => 'kpi_create',
        :constraints => { :destination_id => /\d+/,
                          :cell_id => /[0-9\-]+/,
                          :brand => /.+/,
                          :model => /.+/,
                          :conn_type => /[A-Za-z+\-]+/,
                          :conn_tech => /[A-Za-z+\-]+/,
                          :signal => /[>|<|%3C|%3E]*[0-9.\- ]+|Desconhecido|unknown/,
                          :error_rate => /[>|<|%3C|%3E]*[0-9.\- ]+|Desconhecido|unknown'/,
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
