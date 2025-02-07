class AddRoomToClassrooms < ActiveRecord::Migration[8.0]
  def change
    add_reference :classrooms, :room, null: false, foreign_key: true
  end
end
