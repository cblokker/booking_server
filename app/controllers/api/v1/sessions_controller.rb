module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        super do |user|
          render json: { user: { id: user.id, email: user.email, role: user.role } }, status: :ok and return
        end
      end

      def destroy
        super do
          render json: { message: 'Logged out successfully' }, status: :ok and return
        end
      end
      # include Devise::Controllers::Helpers
      # before_action :authenticate_user!

      # Note: Should go with JWT instead, but wanted to get something up quick
      # def current_u
      #   render json: current_user
      # end


      # Toggle user by ID
      
    end
  end
end
