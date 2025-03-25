class RoomsController < ApplicationController
  before_action :authenticate_person!
  before_action :set_room, only: %i[ show edit update archive unarchive ]
  before_action :authorize_view, only: %i[ show ]
  before_action :authorize_edit, only: %i[ edit update ]
  before_action :authorize_create, only: %i[ new create ]
  before_action :authorize_archive, only: %i[ archive ]
  before_action :authorize_unarchive, only: %i[ unarchive ]

  # GET /rooms or /rooms.json
  def index
    base_scope = helpers.visible_rooms
    @rooms = params[:show_archived] ? base_scope.without_default_scope : base_scope
    @rooms = @rooms.page(params[:page]).per(10)
  end

  # GET /rooms/1 or /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms or /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: "Room was successfully created." }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1 or /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: "Room was successfully updated." }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @room.archive!
    respond_to do |format|
      format.html { redirect_to rooms_path, notice: "Room was successfully archived." }
      format.json { head :no_content }
    end
  end

  def unarchive
    @room.unarchive!
    respond_to do |format|
      format.html { redirect_to rooms_path, notice: "Room was successfully unarchived." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.require(:room).permit(:name, :capacity)
    end

    # Authorization methods
    def authorize_view
      unless helpers.can_view_room?(@room)
        redirect_to rooms_path, alert: "You are not authorized to view this room."
      end
    end

    def authorize_edit
      unless helpers.can_edit_room?(@room)
        redirect_to rooms_path, alert: "You are not authorized to edit this room."
      end
    end

    def authorize_create
      unless helpers.can_create_room?
        redirect_to rooms_path, alert: "You are not authorized to create rooms."
      end
    end

    def authorize_archive
      unless helpers.can_archive_room?(@room)
        redirect_to rooms_path, alert: "You are not authorized to archive this room."
      end
    end

    def authorize_unarchive
      unless helpers.can_unarchive_room?(@room)
        redirect_to rooms_path, alert: "You are not authorized to unarchive this room."
      end
    end
end
