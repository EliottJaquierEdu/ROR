class GradesController < ApplicationController
  before_action :authenticate_person!
  before_action :set_grade, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /grades or /grades.json
  def index
    base_scope = helpers.visible_grades
    @grades = params[:show_archived] ? base_scope.without_default_scope : base_scope
    @grades = @grades.page(params[:page]).per(10)
  end

  # GET /grades/1 or /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    @grade = Grade.new
    @grade.examination_id = params[:examination_id] if params[:examination_id].present?

    # If an examination_id is provided, check if the user can create a grade for this examination
    if params[:examination_id].present?
      examination = Examination.find_by(id: params[:examination_id])
      unless helpers.can_create_grade_for_examination?(examination)
        redirect_to examinations_path, alert: "You are not authorized to create grades for this examination."
        return
      end
      
      # Pre-fill the effective_date with the course's date if available
      if examination.course&.start_at
        @grade.effective_date = examination.course.start_at
      end
    end
  end

  # GET /grades/1/edit
  def edit
  end

  # POST /grades or /grades.json
  def create
    @grade = Grade.new(grade_params)

    # Check if the user can create a grade for this examination
    examination = Examination.find_by(id: @grade.examination_id)
    unless helpers.can_create_grade_for_examination?(examination)
      redirect_to grades_path, alert: "You are not authorized to create grades for this examination."
      return
    end

    # Validate that the student belongs to the examination's course's school class
    if examination&.course&.school_class
      student = Person.find_by(id: @grade.person_id)
      unless student&.school_classes&.include?(examination.course.school_class)
        @grade.errors.add(:person_id, "must be a student in the class associated with this examination")
        render :new, status: :unprocessable_entity
        return
      end
    end

    respond_to do |format|
      if @grade.save
        format.html { redirect_to @grade, notice: "Grade was successfully created." }
        format.json { render :show, status: :created, location: @grade }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grades/1 or /grades/1.json
  def update
    respond_to do |format|
      if @grade.update(grade_params)
        format.html { redirect_to @grade, notice: "Grade was successfully updated." }
        format.json { render :show, status: :ok, location: @grade }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @grade.archive!
    respond_to do |format|
      format.html { redirect_to grades_path, notice: "Grade was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @grade.unarchive!
    respond_to do |format|
      format.html { redirect_to grades_path, notice: "Grade was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.without_default_scope.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grade_params
      params.require(:grade).permit(:value, :effective_date, :person_id, :examination_id)
    end

    # Authorization methods
    def authorize_view
      unless helpers.can_view_grade?(@grade)
        redirect_to grades_path, alert: "You are not authorized to view this grade."
      end
    end

    def authorize_edit
      unless helpers.can_edit_grade?(@grade)
        redirect_to grades_path, alert: "You are not authorized to edit this grade."
      end
    end

    def authorize_create
      unless helpers.can_create_grade?
        redirect_to grades_path, alert: "You are not authorized to create grades."
      end
    end

    def authorize_archive
      unless helpers.can_archive_grade?(@grade)
        redirect_to grades_path, alert: "You are not authorized to archive this grade."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_grade?(@grade)
        redirect_to grades_path, alert: "You are not authorized to unarchive this grade."
      end
    end
end
