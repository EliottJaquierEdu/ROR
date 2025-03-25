class CoursesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_course, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /courses or /courses.json
  def index
    base_scope = helpers.visible_courses
    @courses = params[:show_archived] ? base_scope.without_default_scope : base_scope
    @courses = @courses.page(params[:page]).per(10)
  end

  # GET /courses/1 or /courses/1.json
  def show
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses or /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1 or /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: "Course was successfully updated." }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @course.archive!
    respond_to do |format|
      format.html { redirect_to courses_path, notice: "Course was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @course.unarchive!
    respond_to do |format|
      format.html { redirect_to courses_path, notice: "Course was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.require(:course).permit(:term, :start_at, :end_at, :week_day, :school_class_id, :subject_id)
    end

    # Authorization methods
    def authorize_view
      unless helpers.can_view_course?(@course)
        redirect_to courses_path, alert: "You are not authorized to view this course."
      end
    end

    def authorize_edit
      unless helpers.can_edit_course?(@course)
        redirect_to courses_path, alert: "You are not authorized to edit this course."
      end
    end

    def authorize_create
      unless helpers.can_create_course?
        redirect_to courses_path, alert: "You are not authorized to create courses."
      end
    end

    def authorize_archive
      unless helpers.can_archive_course?(@course)
        redirect_to courses_path, alert: "You are not authorized to archive this course."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_course?(@course)
        redirect_to courses_path, alert: "You are not authorized to unarchive this course."
      end
    end
end
