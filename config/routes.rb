Rails.application.routes.draw do
  get 'home/index'
  devise_for :admin_users, ActiveAdmin::Devise.config
  
  ActiveAdmin.routes(self)
  devise_for :users, sign_out_via: [:get, :delete]

  # Proper routes
  # root "loans#index"
  root 'home#index'

  # get '/loans/list', to: 'loans#index', as: :list_loans  # 👈 Add this FIRST before resources

  resources :loans, only: [:index, :new, :create, :show] do
    member do
      post :repay   # /loans/:id/repay
    end
  end

  get 'risk_score', to: 'loans#assess_risk'

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  
  post "/graphql", to: "graphql#execute"

  resources :loans, only: [:index, :new, :create, :show] do
    resources :repayments, only: [:new, :create]
  end
 

resources :loans
resources :institutions
resources :comments
resources :users
end
