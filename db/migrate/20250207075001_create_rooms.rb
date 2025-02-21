class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false

      t.timestamps
    end

    # Add a unique index on the `name` column
    add_index :rooms, :name, unique: true
  end
end