class CoursesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_course, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create batch_create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /courses or /courses.json
  def index
    base_scope = helpers.visible_courses
    
    # Apply filters
    @filtered_by = {}
    
    if params[:subject_id].present?
      base_scope = base_scope.by_subject(params[:subject_id])
      @filtered_by[:subject] = Subject.find_by(id: params[:subject_id])&.name
    end
    
    if params[:school_class_id].present?
      base_scope = base_scope.by_school_class(params[:school_class_id])
      @filtered_by[:school_class] = SchoolClass.find_by(id: params[:school_class_id])&.name
    end
    
    if params[:term_id].present?
      base_scope = base_scope.by_term(params[:term_id])
      @filtered_by[:term] = Term.find_by(id: params[:term_id])&.name
    end
    
    if params[:teacher_id].present?
      base_scope = base_scope.by_teacher(params[:teacher_id])
      @filtered_by[:teacher] = Person.find_by(id: params[:teacher_id])&.full_name
    end
    
    if params[:weekday].present?
      # Find courses with the specified weekday
      # Need to filter in Ruby since weekday is a calculated field
      @weekday_filter = params[:weekday].to_i
      @filtered_by[:weekday] = Date::DAYNAMES[@weekday_filter]
    end
    
    # Apply archived filter
    @courses = if params[:show_archived]
                 base_scope.without_default_scope.where.not(archived_at: nil)
               else
                 base_scope
               end
               
    # Apply sorting
    @sort_column = params[:sort] || 'subject_id'
    @sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction].to_sym : :asc
    
    # Apply sorting based on column
    case @sort_column
    when 'subject_id'
      @courses = @courses.order_by_subject(@sort_direction)
    when 'term_id'
      @courses = @courses.order_by_term(@sort_direction)
    when 'school_class_id'
      @courses = @courses.order_by_school_class(@sort_direction)
    when 'teacher_id'
      @courses = @courses.order_by_teacher(@sort_direction)  
    when 'start_at'
      @courses = @courses.order(start_at: @sort_direction)
    end
    
    # Apply weekday filter after query if needed (since it's a calculated field)
    if @weekday_filter.present?
      @courses = @courses.select { |course| course.week_day == @weekday_filter }
    end
    
    # Paginate results
    @courses = Kaminari.paginate_array(@courses).page(params[:page]).per(10)
    
    # Load filter options for dropdowns
    @subjects = Subject.order(:name)
    @school_classes = SchoolClass.order(:name)
    @terms = Term.order(:start_at)
    @teachers = Person.teachers.order(:lastname, :firstname)
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

  # GET /courses/batch_new
  def batch_new
    @course = Course.new
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

  # POST /courses/batch_create
  def batch_create
    @course = Course.new(course_params)
    start_date = Date.parse(params[:course][:start_date])
    end_date = Date.parse(params[:course][:end_date])
    target_week_day = @course.start_at.wday

    # Calculate all dates between start_date and end_date that match the week_day
    dates = (start_date..end_date).select { |d| d.wday == target_week_day }

    # Create a course for each date
    courses_created = 0
    errors = []

    dates.each do |date|
      course = Course.new(course_params)
      course.start_at = date.to_time.change(
        hour: @course.start_at.hour,
        min: @course.start_at.min
      )
      course.end_at = date.to_time.change(
        hour: @course.end_at.hour,
        min: @course.end_at.min
      )
      
      # Ensure the course is within the term's date range
      term = Term.find(course.term_id)
      if date < term.start_at || date > term.end_at
        errors << "Course for #{date} is outside the term's date range (#{term.start_at.to_date} to #{term.end_at.to_date})"
        next
      end
      
      if course.save
        courses_created += 1
      else
        errors << "Failed to create course for #{date}: #{course.errors.full_messages.join(', ')}"
      end
    end

    respond_to do |format|
      if errors.empty?
        format.html { redirect_to courses_path, notice: "Successfully created #{courses_created} courses." }
      else
        format.html { 
          flash.now[:alert] = "Created #{courses_created} courses with errors: #{errors.join('; ')}"
          render :batch_new, status: :unprocessable_entity 
        }
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
      # Preserve filter and sort parameters when redirecting
      preserved_params = params.permit(:subject_id, :school_class_id, :term_id, :teacher_id, :weekday, :sort, :direction, :show_archived)
      format.html { redirect_to courses_path(preserved_params), notice: "Course was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @course.unarchive!
    respond_to do |format|
      # Preserve filter and sort parameters when redirecting
      preserved_params = params.permit(:subject_id, :school_class_id, :term_id, :teacher_id, :weekday, :sort, :direction, :show_archived)
      format.html { redirect_to courses_path(preserved_params), notice: "Course was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.without_default_scope.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def course_params
      params.require(:course).permit(:term_id, :start_at, :end_at, :school_class_id, :subject_id, :teacher_id)
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
