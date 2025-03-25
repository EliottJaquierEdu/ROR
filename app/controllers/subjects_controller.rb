class SubjectsController < ApplicationController
  before_action :authenticate_person!
  before_action :set_subject, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /subjects or /subjects.json
  def index
    base_scope = helpers.visible_subjects
    @subjects = params[:show_archived] ? base_scope.without_default_scope : base_scope
    @subjects = @subjects.page(params[:page]).per(10)
  end

  # GET /subjects/1 or /subjects/1.json
  def show
    @selected_week = params[:week] ? Date.parse(params[:week]) : Date.current
    @weekly_courses = @subject.courses_for_week(@selected_week)
  end

  # GET /subjects/new
  def new
    @subject = Subject.new
  end

  # GET /subjects/1/edit
  def edit
  end

  # POST /subjects or /subjects.json
  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      redirect_to @subject, notice: 'Subject was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subjects/1 or /subjects/1.json
  def update
    if @subject.update(subject_params)
      redirect_to @subject, notice: 'Subject was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @subject.archive!
    respond_to do |format|
      format.html { redirect_to subjects_path, notice: "Subject was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @subject.unarchive!
    respond_to do |format|
      format.html { redirect_to subjects_path, notice: "Subject was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subject_params
      params.require(:subject).permit(:name)
    end

    def authorize_view
      unless helpers.can_view_subject?(@subject)
        redirect_to subjects_path, alert: 'You are not authorized to view this subject.'
      end
    end

    def authorize_edit
      unless helpers.can_edit_subject?(@subject)
        redirect_to subjects_path, alert: 'You are not authorized to edit this subject.'
      end
    end

    def authorize_create
      unless helpers.can_create_subject?
        redirect_to subjects_path, alert: 'You are not authorized to create subjects.'
      end
    end

    def authorize_archive
      unless helpers.can_archive_subject?(@subject)
        redirect_to subjects_path, alert: "You are not authorized to archive this subject."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_subject?(@subject)
        redirect_to subjects_path, alert: "You are not authorized to unarchive this subject."
      end
    end
end
