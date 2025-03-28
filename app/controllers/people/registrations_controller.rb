class People::RegistrationsController < Devise::RegistrationsController
  respond_to :html, :turbo_stream
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :username, :firstname, :lastname, :phone_number, :type,
      :student_status_id, :teacher_status_id,
      address_attributes: [:zip, :town, :street, :number]
    ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :username, :firstname, :lastname, :phone_number,
      :student_status_id, :teacher_status_id,
      address_attributes: [:zip, :town, :street, :number]
    ])
  end

  def respond_with(resource, _opts = {})
    if request.format.turbo_stream?
      if resource.persisted?
        redirect_to after_sign_up_path_for(resource), notice: "Welcome! You have signed up successfully."
      else
        render :new, status: :unprocessable_entity
      end
    else
      super
    end
  end

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_update_path_for(resource)
    stored_location_for(resource) || edit_registration_path(resource)
  end
end
