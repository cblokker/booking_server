module Api
  module V1
    class UsersController < ApplicationController
      
      # TODO: Move to query object
      def index
        @users = if params[:role] == 'coach'
          User.coaches
        elsif params[:role] == 'student'
          User.students
        else
          User.all
        end

        render json: @users
      end

      # TODO: Switch to JWT
      def show_current_user
        if user_signed_in?
          render json: current_user, status: :ok
        else
          render json: { error: 'No user logged in' }, status: :unauthorized
        end
      end

      def switch_user
        target_user = User.find_by(id: params[:user_id])
    
        if target_user
          sign_out(current_user) if current_user
          sign_in(target_user)

          render json: current_user, status: :ok
        else
          render json: { error: "User not found" }, status: :not_found
        end
      end
    end
  end
end
