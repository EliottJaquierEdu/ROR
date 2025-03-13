class People::SessionsController < Devise::SessionsController
  respond_to :html, :turbo_stream

  # Override create to properly handle the response
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?

    # Ensure we're responding with a proper format, not the raw resource
    respond_with(resource) do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.json { render json: { success: true } }
      format.turbo_stream { redirect_to after_sign_in_path_for(resource) }
    end
  end

  protected

  def respond_to_on_destroy
    if request.format.turbo_stream?
      redirect_to after_sign_out_path_for(resource_name), notice: "Signed out successfully."
    else
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) { redirect_to after_sign_out_path_for(resource_name) }
      end
    end
  end
end
