Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: { sessions: 'api/v1/sessions' }
      get '/show_current_user', to: 'users#show_current_user'
      post '/switch_user', to: 'users#switch_user'

      resources :coaches, only: [] do
        # resources :availability_windows, only: [:index] do # current_user (coach)
        #   collection do
        #     put :bulk_update # current_user (coach)
        #   end
        # end
        resources :availability_slots, only: [:index] # global (for students)
        # resources :bookings, only: [:index] do # current_user (coach)
        #   collection do
        #     put :complete # current_user (coach)
        #   end
        # end
      end

      # resources :students, only: [] do
      #   resources :bookings, only: [:index] # current_user (student)
      # end

      # User I Wany
      resources :users, only: [:index, :show] # global (for students)

      resources :availability_windows, only: [:index] do # current_user (coach)
        collection do
          put :bulk_update # current_user (coach)
        end
      end
  
      # bookings I want
      resources :bookings, only: [:index, :create] do
        put :complete
      end
    end
  end
end
