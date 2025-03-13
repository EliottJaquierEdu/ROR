class People::SessionsController < Devise::SessionsController
  respond_to :html, :turbo_stream

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
