Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: { sessions: 'api/v1/sessions' }
      get '/show_current_user', to: 'users#show_current_user'
      post '/switch_user', to: 'users#switch_user'
      # devise_for :users, controllers: {
      #   sessions: 'api/v1/sessions'
      # }

      # devise_scope :user do
      #   get 'current_u', to: 'sessions#current_u'
      #   post 'switch_user', to: 'sessions#switch_user'
      # end
      # get 'current_u', to: 'custom_sessions#current_u'
      # post 'switch_user', to: 'custom_sessions#switch_user'
      # devise_for :users, controllers: {
      #   sessions: 'api/sessions'
      # }

      # devise_scope :user do
      #   get 'show_current_user', to: 'sessions#show_current_user'
      #   post 'switch_user', to: 'sessions#switch_user'
      # end

      # resources :sessions, only: :show
      # post 'switch_user', to: 'sessions#switch'
      # get 'current_user', to: 'current_user#show'

      resources :coaches, only: [] do
        resources :availability_windows, only: [:index] do
          collection do
            put :bulk_update  
          end
        end
        resources :availability_slots, only: :index
      end

      resources :users, only: [:index, :show]

      # post '/switch_user', to: 'users#switch_user'

     
      # resources :availability_windows, only: [:index, :create, :update, :destroy] do
      #   collection do
      #     put :bulk_update
      #   end
      # end
      # resources :bookings, only: [:index, :create, :update, :destroy]
      # resources :users, only: [:index]


      # resources :coaches, only: [] do
      #   resources :availability_windows, only: [:index, :create, :update, :destroy] do
      #     get :slots, to: 'precomputed_slots#index'
      #   end
      # end

      # resources :students, only: [] do
      #   resources :bookings, only: [:index, :create, :update, :destroy]
      # end

      # resources :bookings, only: [:index, :create, :update, :destroy]
    end
  end
end
