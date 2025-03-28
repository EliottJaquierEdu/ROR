class ExaminationsController < ApplicationController
  before_action :authenticate_person!
  before_action :set_examination, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /examinations or /examinations.json
  def index
    base_scope = helpers.visible_examinations
    @examinations = params[:show_archived] ? base_scope.without_default_scope : base_scope
    @examinations = @examinations.page(params[:page]).per(10)
  end

  # GET /examinations/1 or /examinations/1.json
  def show
  end

  # GET /examinations/new
  def new
    @examination = Examination.new
    @examination.course_id = params[:course_id] if params[:course_id].present?

    # If a course_id is provided, check if the user can create an examination for this course
    if params[:course_id].present?
      course = Course.find_by(id: params[:course_id])
      unless helpers.can_create_examination_for_course?(course)
        redirect_to courses_path, alert: "You are not authorized to create examinations for this course."
        return
      end
    end
  end

  # GET /examinations/1/edit
  def edit
  end

  # POST /examinations or /examinations.json
  def create
    @examination = Examination.new(examination_params)

    # Check if the user can create an examination for this course
    unless helpers.can_create_examination_for_course?(Course.find_by(id: @examination.course_id))
      redirect_to examinations_path, alert: "You are not authorized to create examinations for this course."
      return
    end

    respond_to do |format|
      if @examination.save
        format.html { redirect_to @examination, notice: "Examination was successfully created." }
        format.json { render :show, status: :created, location: @examination }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /examinations/1 or /examinations/1.json
  def update
    respond_to do |format|
      if @examination.update(examination_params)
        format.html { redirect_to @examination, notice: "Examination was successfully updated." }
        format.json { render :show, status: :ok, location: @examination }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @examination.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @examination.archive!
    respond_to do |format|
      format.html { redirect_to examinations_path, notice: "Examination was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @examination.unarchive!
    respond_to do |format|
      format.html { redirect_to examinations_path, notice: "Examination was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_examination
      @examination = Examination.without_default_scope.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def examination_params
      params.require(:examination).permit(:title, :course_id)
    end

    # Authorization methods
    def authorize_view
      unless helpers.can_view_examination?(@examination)
        redirect_to examinations_path, alert: "You are not authorized to view this examination."
      end
    end

    def authorize_edit
      unless helpers.can_edit_examination?(@examination)
        redirect_to examinations_path, alert: "You are not authorized to edit this examination."
      end
    end

    def authorize_create
      unless helpers.can_create_examination?
        redirect_to examinations_path, alert: "You are not authorized to create examinations."
      end
    end

    def authorize_archive
      unless helpers.can_archive_examination?(@examination)
        redirect_to examinations_path, alert: "You are not authorized to archive this examination."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_examination?(@examination)
        redirect_to examinations_path, alert: "You are not authorized to unarchive this examination."
      end
    end
end
