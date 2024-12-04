module Api
  module V1
    class BaseController < ActionController::API
      include Devise::Controllers::Helpers

      # before_action :authenticate_user!

      # Use this helper in derived controllers
      # def current_user
      #   super
      # end
    end
  end
end