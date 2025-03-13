class GradesController < ApplicationController
  before_action :set_grade, only: %i[ show edit update destroy ]
  before_action :authorize_grade_access, only: %i[ show edit update destroy ]
  before_action :authorize_grade_management, only: %i[ new create edit update destroy ]

  # GET /grades or /grades.json
  def index
    @grades = if current_person.dean? || current_person.teacher?
      Grade.all
    else
      current_person.grades
    end
  end

  # GET /grades/1 or /grades/1.json
  def show
  end

  # GET /grades/new
  def new
    @grade = Grade.new
  end

  # GET /grades/1/edit
  def edit
  end

  # POST /grades or /grades.json
  def create
    @grade = Grade.new(grade_params)

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

  # DELETE /grades/1 or /grades/1.json
  def destroy
    @grade.destroy!

    respond_to do |format|
      format.html { redirect_to grades_path, status: :see_other, notice: "Grade was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade
      @grade = Grade.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def grade_params
      params.require(:grade).permit(:value, :effective_date, :person_id, :examination_id)
    end

    def authorize_grade_access
      unless current_person.can_view_grade?(@grade)
        flash[:alert] = "You are not authorized to access this grade."
        redirect_to grades_path
      end
    end

    def authorize_grade_management
      unless current_person.can_manage_resources?
        flash[:alert] = "Only deans can manage grades."
        redirect_to grades_path
      end
    end
end
