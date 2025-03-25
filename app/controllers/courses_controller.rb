class CoursesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_course, only: %i[ show edit update destroy ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_delete, only: %i[ destroy ]

  # GET /courses or /courses.json
  def index
    @courses = helpers.visible_courses

    # Apply filters
    @courses = @courses.where(term: params[:term]) if params[:term].present?
    @courses = @courses.where(week_day: params[:week_day]) if params[:week_day].present?
    @courses = @courses.joins(:school_class).where(school_classes: { year: params[:year] }) if params[:year].present?
    @courses = @courses.joins(:subject).where(subjects: { id: params[:subject_id] }) if params[:subject_id].present?

    # Apply sorting
    sort_column = %w[term week_day start_at school_classes.name subjects.name].include?(params[:sort]) ? params[:sort] : 'term'
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'

    @courses = @courses.joins(:school_class, :subject)
                      .order("#{sort_column} #{sort_direction}")
                      .includes(:school_class, :subject) # Eager load associations
                      .page(params[:page]).per(10) # Add pagination with 10 items per page
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

  # DELETE /courses/1 or /courses/1.json
  def destroy
    @course.destroy!

    respond_to do |format|
      format.html { redirect_to courses_path, status: :see_other, notice: "Course was successfully destroyed." }
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

    def authorize_delete
      unless helpers.can_delete_course?(@course)
        redirect_to courses_path, alert: "You are not authorized to delete this course."
      end
    end
end
