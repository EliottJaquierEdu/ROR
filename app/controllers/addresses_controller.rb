class AddressesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_address, only: %i[ show edit update destroy ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_delete, only: %i[ destroy ]

  # GET /addresses or /addresses.json
  def index
    @addresses = helpers.visible_addresses
                       .page(params[:page]).per(10)
  end

  # GET /addresses/1 or /addresses/1.json
  def show
  end

  # GET /addresses/new
  def new
    @address = Address.new
    @address.person_id = params[:person_id] if params[:person_id].present?
  end

  # GET /addresses/1/edit
  def edit
  end

  # POST /addresses or /addresses.json
  def create
    @address = Address.new(address_params)

    respond_to do |format|
      if @address.save
        format.html { redirect_to @address, notice: "Address was successfully created." }
        format.json { render :show, status: :created, location: @address }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /addresses/1 or /addresses/1.json
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to @address, notice: "Address was successfully updated." }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /addresses/1 or /addresses/1.json
  def destroy
    @address.destroy!

    respond_to do |format|
      format.html { redirect_to addresses_path, status: :see_other, notice: "Address was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      @address = Address.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def address_params
      params.require(:address).permit(:zip, :town, :street, :number, :person_id)
    end

    # Authorization methods
    def authorize_view
      unless helpers.can_view_address?(@address)
        redirect_to addresses_path, alert: "You are not authorized to view this address."
      end
    end

    def authorize_edit
      unless helpers.can_edit_address?(@address)
        redirect_to addresses_path, alert: "You are not authorized to edit this address."
      end
    end

    def authorize_create
      unless helpers.can_create_address?
        redirect_to addresses_path, alert: "You are not authorized to create addresses."
      end
    end

    def authorize_delete
      unless helpers.can_delete_address?(@address)
        redirect_to addresses_path, alert: "You are not authorized to delete this address."
      end
    end
end
