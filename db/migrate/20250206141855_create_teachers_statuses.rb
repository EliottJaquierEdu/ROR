class CreateTeachersStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :teachers_statuses do |t|
      t.string :status, null: false

      t.timestamps
    end
  end
end
