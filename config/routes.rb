Rails.application.routes.draw do
  namespace :student do
    get :signup, to: 'signups#new'
    post :accounts, to: "signups#create"

    resource :dashboard, only: :show

    resources :mentors, only: :show

    resource :mentor_search, only: :show

    resources :teams, except: :delete
    resources :team_memberships, only: :destroy

    resources :team_member_invites, except: [:edit, :update, :destroy]
    resources :mentor_invites, only: [:create]
    resources :join_requests, only: [:new, :create, :update]

    resources :team_searches, except: [:index, :destroy]

    resource :account, only: [:show, :edit, :update]
  end

  namespace :mentor do
    get :signup, to: 'signups#new'
    post :accounts, to: "signups#create"

    resources :teams, only: [:index, :show]
    resources :team_searches, except: [:index, :destroy]
    resources :join_requests, except: [:edit, :update]

    resource :dashboard, only: :show

    resources :mentor_invites, only: [:show, :update]

    resource :account, only: [:show, :edit, :update]
  end

  namespace :coach do
    get :signup, to: 'signups#new'
    post :accounts, to: "signups#create"

    resource :dashboard, only: :show
  end

  namespace :regional_ambassador do
    get :signup, to: 'signups#new'
    post :accounts, to: "signups#create"

    resource :dashboard, only: :show
  end

  namespace :judge do
    get :signup, to: 'signups#new'
    post :accounts, to: "signups#create"

    resource :dashboard, only: :show

    resources :scores, only: :index

    resources :submissions, only: [] do
      resources :scores
    end
  end

  namespace :admin do
    resources :score_categories
    resources :pending_regional_ambassadors, only: [:index, :update]

    root to: 'dashboards#index'
  end

  namespace :application do
    resource :dashboard, only: :show
  end

  resources :parental_consents, only: [:new, :create, :show]

  resources :teams, only: :show
  resources :team_member_invites, only: [:show, :update]

  get 'login', to: 'signins#new', as: :login
  get 'signin', to: 'signins#new', as: :signin

  get 'signup', to: 'signups#new', as: :signup

  match 'logout',  to: 'signins#destroy', as: :logout, via: [:get, :delete]
  match 'signout', to: 'signins#destroy', as: :signout, via: [:get, :delete]

  resources :signins, only: :create

  root to: "application/dashboards#show"
end
