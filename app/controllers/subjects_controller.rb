class SubjectsController < ApplicationController
  before_action :authenticate_person!
  before_action :set_subject, only: [:show, :edit, :update, :destroy]
  before_action :authorize_view, only: [:index, :show]
  before_action :authorize_edit, only: [:edit, :update]
  before_action :authorize_create, only: [:new, :create]
  before_action :authorize_delete, only: [:destroy]

  # GET /subjects or /subjects.json
  def index
    @subjects = helpers.visible_subjects
  end

  # GET /subjects/1 or /subjects/1.json
  def show
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

  # DELETE /subjects/1 or /subjects/1.json
  def destroy
    @subject.destroy
    redirect_to subjects_url, notice: 'Subject was successfully deleted.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subject
      @subject = Subject.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subject_params
      params.require(:subject).permit(:name, :description)
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

    def authorize_delete
      unless helpers.can_delete_subject?(@subject)
        redirect_to subjects_path, alert: 'You are not authorized to delete this subject.'
      end
    end
end
