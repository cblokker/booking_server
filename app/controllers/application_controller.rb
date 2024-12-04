class ApplicationController < ActionController::API
  include ActionController::Helpers
  include Devise::Controllers::Helpers
  

  # skip_before_action :verify_authenticity_token, if: :devise_controller?
end
