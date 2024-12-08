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
    end
  end
end
