class SchoolClassesController < ApplicationController
  before_action :set_scool_class, only: %i[ show edit update destroy ]

  # GET /scool_classes or /scool_classes.json
  def index
    @scool_classes = SchoolClass.all
  end

  # GET /scool_classes/1 or /scool_classes/1.json
  def show
  end

  # GET /scool_classes/new
  def new
    @scool_class = SchoolClass.new
  end

  # GET /scool_classes/1/edit
  def edit
  end

  # POST /scool_classes or /scool_classes.json
  def create
    @scool_class = SchoolClass.new(scool_class_params)

    respond_to do |format|
      if @scool_class.save
        format.html { redirect_to @scool_class, notice: "SchoolClass was successfully created." }
        format.json { render :show, status: :created, location: @scool_class }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @scool_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scool_classes/1 or /scool_classes/1.json
  def update
    respond_to do |format|
      if @scool_class.update(scool_class_params)
        format.html { redirect_to @scool_class, notice: "SchoolClass was successfully updated." }
        format.json { render :show, status: :ok, location: @scool_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @scool_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scool_classes/1 or /scool_classes/1.json
  def destroy
    @scool_class.destroy!

    respond_to do |format|
      format.html { redirect_to scool_classes_path, status: :see_other, notice: "SchoolClass was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scool_class
      @scool_class = SchoolClass.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def scool_class_params
      params.expect(scool_class: [ :uid, :name, :room_id, :master ])
    end
end
