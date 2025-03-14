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

  def authorize_resource_management
    unless current_person.can_manage_resources?
      flash[:alert] = "You are not authorized to manage this resource."
      redirect_back(fallback_location: root_path)
    end
  end
end
