class AddTeacherStatusToPeople < ActiveRecord::Migration[8.0]
  def change
    add_reference :people, :teacher_status, null: false, foreign_key: { to_table: :teachers_statuses }
  end
end
