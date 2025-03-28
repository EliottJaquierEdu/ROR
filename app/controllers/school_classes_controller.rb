class SchoolClassesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_school_class, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /school_classes or /school_classes.json
  def index
    base_scope = helpers.visible_school_classes
    @school_classes = if params[:show_archived]
                       base_scope.without_default_scope.where.not(archived_at: nil)
                     else
                       base_scope
                     end
    @school_classes = @school_classes.page(params[:page]).per(10)
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

  def archive
    @school_class.archive!
    respond_to do |format|
      format.html { redirect_to school_classes_path, notice: "School class was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @school_class.unarchive!
    respond_to do |format|
      format.html { redirect_to school_classes_path, notice: "School class was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school_class
      @school_class = SchoolClass.without_default_scope.find(params[:id])
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

    def authorize_archive
      unless helpers.can_archive_school_class?(@school_class)
        redirect_to school_classes_path, alert: "You are not authorized to archive this school class."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_school_class?(@school_class)
        redirect_to school_classes_path, alert: "You are not authorized to unarchive this school class."
      end
    end
end
