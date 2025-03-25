class PeopleController < ApplicationController
  before_action :authenticate_person!
  before_action :set_person, only: %i[ show edit update destroy ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_delete, only: %i[ destroy ]

  # GET /people or /people.json
  def index
    @people = helpers.visible_people_by_type(params[:type])
  end

  # GET /people/1 or /people/1.json
  def show
    # Get the selected week (default to current week)
    @selected_week = params[:week] ? Date.parse(params[:week]) : Date.current.beginning_of_week
    week_start = @selected_week.beginning_of_week
    week_end = @selected_week.end_of_week

    # If we're showing a student, preload their grades with associations for the grade report
    if @person.student?
      # This will trigger the grades_with_associations method
      @person.grades_with_associations.to_a
    end

    # If we're showing a teacher, filter their courses for the selected week
    if @person.teacher?
      @week_courses = @person.courses
                            .includes(:subject)
                            .where(week_day: 1..5)
                            .where("DATE(start_at) BETWEEN ? AND ?", week_start, week_end)
                            .order(:week_day, :start_at)
    end
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people or /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: "Person was successfully created." }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1 or /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person, notice: "Person was successfully updated." }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1 or /people/1.json
  def destroy
    @person.destroy!

    respond_to do |format|
      format.html { redirect_to people_path, status: :see_other, notice: "Person was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def person_params
      params.require(:person).permit(:firstname, :lastname, :email, :type, :password, :password_confirmation)
    end

    # Authorization methods
    def authorize_view
      unless helpers.can_view_person?(@person)
        redirect_to people_path, alert: "You are not authorized to view this person."
      end
    end

    def authorize_edit
      unless helpers.can_edit_person?(@person)
        redirect_to people_path, alert: "You are not authorized to edit this person."
      end
    end

    def authorize_create
      unless helpers.can_create_person?
        redirect_to people_path, alert: "You are not authorized to create people."
      end
    end

    def authorize_delete
      unless helpers.can_delete_person?(@person)
        redirect_to people_path, alert: "You are not authorized to delete this person."
      end
    end
end
