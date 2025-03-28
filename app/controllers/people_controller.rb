class PeopleController < ApplicationController
  before_action :authenticate_person!
  before_action :set_person, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /people or /people.json
  def index
    base_scope = helpers.visible_people_by_type(params[:type])
    @people = if params[:show_archived]
                base_scope.where.not(archived_at: nil)
              else
                base_scope.where(archived_at: nil)
              end
    @people = @people.page(params[:page]).per(10)
  end

  # GET /people/1 or /people/1.json
  def show
    @selected_week = params[:week] ? Date.parse(params[:week]) : Date.current.beginning_of_week

    # Load all necessary data based on person type
    data = @person.load_show_data(@selected_week)

    if @person.teacher?
      @school_classes = data[:school_classes]
      @week_courses = data[:week_courses]
    elsif @person.student?
      @school_classes = data[:school_classes]
      @week_courses = Course.joins(:school_class)
                           .joins('INNER JOIN people_school_classes ON school_classes.id = people_school_classes.school_class_id')
                           .where(people_school_classes: { person_id: @person.id })
                           .where(start_at: @selected_week.beginning_of_week..@selected_week.end_of_week)
                           .distinct
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
  def archive
    @person.archive!

    respond_to do |format|
      format.html { redirect_to people_path, status: :see_other, notice: "#{@person.full_name} was successfully archived." }
      format.json { head :no_content }
    end
  end

  # PATCH /people/1/unarchive
  def unarchive
    @person.unarchive!

    respond_to do |format|
      format.html { redirect_to people_path, status: :see_other, notice: "#{@person.full_name} was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.without_default_scope.find(params[:id])
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

    def authorize_archive
      unless helpers.can_archive_person?(@person)
        redirect_to people_path, alert: "You are not authorized to archive this person."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_person?(@person)
        redirect_to people_path, alert: "You are not authorized to unarchive this person."
      end
    end
end
