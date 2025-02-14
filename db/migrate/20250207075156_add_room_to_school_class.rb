class AddRoomToSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    add_reference :scool_classes, :room, null: false, foreign_key: true
  end
end
