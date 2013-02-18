MomRails::Application.routes.draw do
  resources :metrics
  resources :tests
  resources :schedules
  resources :probes
  resources :metrics
  resources :profiles
  resources :connection_profiles do
    resources :plans
  end
  resources :thresholds
  resources :plans

  devise_for :users
  resources :users

  devise_for :users #, :controllers => { :registrations => "registrations" }
  resources :users do
    get :active
  end

  get 'users/sign_in'

  get 'welcome/index'

  #match collect
  match 'collect/id' => 'results#index'
  match 'collect/id/:destination_id/:metric/:ds_max/:ds_min/:ds_avg/:sd_max/:sd_min/:sd_avg/:timestamp/:uuid' => 'results#create',
        :via => [:get],
        :as => 'results_create',
        :constraints => { :destination_id => /\d+/,
                          :metric => /[a-z_]+/,
                          :ds_max => /[-]*[0-9]+[.]*[0-9]+/,
                          :ds_min => /[-]*[0-9]+[.]*[0-9]+/,
                          :ds_avg => /[-]*[0-9]+[.]*[0-9]+/,
                          :sd_max => /[-]*[0-9]+[.]*[0-9]+/,
                          :sd_min => /[-]*[0-9]+[.]*[0-9]+/,
                          :sd_avg => /[-]*[0-9]+[.]*[0-9]+/,
                          :timestamp => /\d+/,
                          :uuid => /[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+/
        }

  match 'collect/id/:destination_id/kpis/:cellid/:brand/:model/:conntype/:conntech/:signal/:errorrate/:numberofips/:route/:mtu/:dnslatency/:lac/:timestamp/:uuid' => 'kpi#create',
        :via => [:get],
        :as => 'kpi_create',
        :constraints => { :destination_id => /\d+/,
                          :cellid => /[0-9\-]+/,
                          :brand => /.+/,
                          :model => /.+/,
                          :conntype => /[A-Za-z\-]+/,
                          :conntech => /[A-Za-z\-]+/,
                          :signal => /[>|<]*[0-9.\- ]+|Desconhecido|unknown/,
                          :errorrate => /[>|<]*[0-9.\- ]+|Desconhecido|unknown'/,
                          :numberofips => /[0-9\-]+/,
                          :route => /.+/,
                          :mtu => /[0-9\-]+|Desconhecido/,
                          :dnslatency => /[0-9.\- ><]+|Desconhecido/,
                          :lac => /[-]*[0-9 ><]+/,
                          :timestamp => /\d+/,
                          :uuid => /[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+/
        }

  match 'schedules/unused_profiles_form/:source_id/:destination_id' => 'schedules#unused_profiles_form'

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
