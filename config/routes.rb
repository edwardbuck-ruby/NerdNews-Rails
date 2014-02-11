Nerdnews::Application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :stories
    end
  end

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
    controllers :authorizations => 'oauth/authorizations'
    controllers :authorized_applications => 'oauth/authorized_applications'
  end

  post "share_by_mail/create"
  get "share_by_mail/show"

  # generated by under_construction gem
  # match "under_construction", :to => redirect('/')

  root :to => "stories#index"

  get "/faq" => "static_pages#faq", as: "static_pages_faq"

  # delayed job web inteface
  get "/delayed_job" => DelayedJobWeb, :anchor => false

  # External Auth
  get '/auth/:provider/callback' => 'identities#create'
  get '/auth/failure' => 'identities#failure'

  # Identities (Used for OmniAuth)
  resources :identities, :only => [:index, :create, :destroy] do
    collection do
      get 'signup'
    end
  end

  # Other Resources
  resources :activity_logs
  resources :ratings
  resources :password_resets
  resources :pages
  resources :tags do
    collection do
      delete 'destroy_multiple'
    end
  end
  resources :mypage, only: :index
  resources :announcements do
    get :hide, on: :member
  end

  # Sessions
  get "/login" => "sessions#new", as: "new_session"
  post "/login" => "sessions#create", as: "sessions"
  delete "/logout" => "sessions#destroy", as: "session"

  # Users
  resources :users, path_names: { new: 'sign_up' } do
    get 'posts', on: :member
    get 'comments', on: :member
    get 'favorites', on: :member
    get 'activity_logs', on: :member
    post 'add_to_favorites', on: :member
    resources :messages, except: [:edit, :update, :show], path_names: { new: 'new' }
  end

  # Stories
  resources :stories do
    resources :votes, :defaults => { :voteable => 'stories' }
    resources :comments, :except => :index do
      put "mark_as_spam", :on => :member
      put "mark_as_not_spam", :on => :member
      resources :votes, :defaults => { :voteable => 'comments' }
    end
    get 'unpublished', :on => :collection
    put 'publish', :on => :member
    get 'recent', on: :collection
  end

  get "/comments" => "comments#index"
  delete "/comments/destroy_spams" => 'comments#destroy_spams'

  get "/:permalink" => "pages#show", as: "page_by_permalink"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
