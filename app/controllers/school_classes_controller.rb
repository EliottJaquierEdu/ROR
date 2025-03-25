class SchoolClassesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_school_class, only: [:show, :edit, :update, :destroy]
  before_action :authorize_view, only: [:show]
  before_action :authorize_edit, only: [:edit, :update]
  before_action :authorize_create, only: [:new, :create]
  before_action :authorize_delete, only: [:destroy]

  # GET /school_classes or /school_classes.json
  def index
    @school_classes = helpers.visible_school_classes
                            .includes(:master, :room, :students)
  end

  # GET /school_classes/1 or /school_classes/1.json
  def show
    @selected_week = params[:week] ? Date.parse(params[:week]) : Date.current
    @week_courses = @school_class.courses_for_week(@selected_week)
  end

  # GET /school_classes/new
  def new
    @school_class = SchoolClass.new
  end

  # GET /school_classes/1/edit
  def edit
  end

  # POST /school_classes or /school_classes.json
  def create
    @school_class = SchoolClass.new(school_class_params)

    if @school_class.save
      redirect_to @school_class, notice: 'Class was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /school_classes/1 or /school_classes/1.json
  def update
    if @school_class.update(school_class_params)
      redirect_to @school_class, notice: 'Class was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /school_classes/1 or /school_classes/1.json
  def destroy
    @school_class.destroy
    redirect_to school_classes_url, notice: 'Class was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_class
      @school_class = SchoolClass.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def school_class_params
      params.require(:school_class).permit(:year, :name, :master_id, :room_id)
    end

    def authorize_view
      unless helpers.can_view_school_class?(@school_class)
        redirect_to school_classes_path, alert: 'You are not authorized to view this class.'
      end
    end

    def authorize_edit
      unless helpers.can_edit_school_class?(@school_class)
        redirect_to school_classes_path, alert: 'You are not authorized to edit this class.'
      end
    end

    def authorize_create
      unless helpers.can_create_school_class?
        redirect_to school_classes_path, alert: 'You are not authorized to create classes.'
      end
    end

    def authorize_delete
      unless helpers.can_delete_school_class?(@school_class)
        redirect_to school_classes_path, alert: 'You are not authorized to delete this class.'
      end
    end
end
