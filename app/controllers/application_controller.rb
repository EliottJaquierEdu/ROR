class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_person!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :firstname, :lastname, :phone_number, :type,
                                                      address_attributes: [:zip, :town, :street, :number]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :firstname, :lastname, :phone_number,
                                                            address_attributes: [:zip, :town, :street, :number]])
  end
end
