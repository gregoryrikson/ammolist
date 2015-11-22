Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  resources :ammolist_taxon_calibers
  resources :guest_user_ips, only: [:index, :destroy] do
    collection do
      post 'block_guest'
    end
  end
  #resources :customs, :only => [:index]
  
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'
          # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'taxons/all_products', to: 'spree/taxons#all_products', as: :taxon_all_products
  get 'taxons/taxons_products', to: 'spree/taxons#taxons_products', as: :taxons_products
  get 'taxons/taxon_product_info', to: 'spree/taxons#taxon_product_info', as: :taxon_product_info
  get 'taxons/taxon_update_point', to: 'spree/taxons#taxon_update_point', as: :taxon_update_point
  get 'taxons/taxon_update_user_ammolist', to: 'spree/taxons#taxon_update_user_ammolist', as: :taxon_update_user_ammolist
  get 'taxons/taxon_subscribe_user_ammolist', to: 'spree/taxons#taxon_subscribe_user_ammolist', as: :taxon_subscribe_user_ammolist
  get 'taxons/taxon_get_user_ammolist', to: 'spree/taxons#taxon_get_user_ammolist', as: :taxon_get_user_ammolist
  get 'subscriptions/subscribe', to: 'spree/subscriptions#subscribe', as: :email_subscribe
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  comfy_route :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_path

  scope :module => :comfy, :as => :comfy do
    scope :module => :admin do
      namespace :cms, :as => :admin_cms, :path => 'admin', :except => :show do
        scope :path => ComfortableMexicanSofa.config.cms_route_path do
          resources :sites do
            resources :shared_media
          end
        end
      end
    end

    scope :module => :cms do
      scope :path => ComfortableMexicanSofa.config.cms_route_path do
        get 'feed' => 'content#feed', :as => 'feed'
      end
    end
  end

  # Make sure this routeset is defined last
  comfy_route :cms, :path => ComfortableMexicanSofa.config.cms_route_path, :sitemap => false
  
end

Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :shipping_constraints
    resources :constraint_types
    resources :ammunitions
    
    resources :products do
      resources :questions
    end
    
    resources :questions, only: [] do
      collection do
        get :pending
      end
    end
    
  end
  
  resources :questions, only: [:create]
  
  post '/checkout/update_delivery', :to => 'checkout#update_delivery', :as => :checkout_update_delivery
  post '/checkout/update_shipment_upgrade', :to => 'checkout#update_shipment_upgrade', :as => :checkout_update_shipment_upgrade
  post '/checkout/summary', :to => 'checkout#summary', :as => :checkout_summary
  get '/customs/bloked_user', :to => 'customs#bloked_user', :as => :customs_bloked_user
  get '/customs/blocked_guest', :to => 'customs#blocked_guest', :as => :customs_blocked_guest
  post '/admin/orders/update_shipment_upgrade', :to => 'admin/orders#update_shipment_upgrade', :as => :checkout_update_shipment_upgrade_admin
end
