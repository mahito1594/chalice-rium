class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Allow all browsers in development for using Firefox's developer tools.
  allow_browser versions: :modern unless Rails.env.development?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username display_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username display_name])
  end
end
