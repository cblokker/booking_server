module SessionEnabled
  extend ActiveSupport::Concern

  included do
    before_action :enable_session
  end

  private

  def enable_session
    request.session_options[:skip] = false
  end
end
