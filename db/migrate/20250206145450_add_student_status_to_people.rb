class AddStudentStatusToPeople < ActiveRecord::Migration[8.0]
  def change
    add_reference :people, :student_status, null: false, foreign_key: true
  end
end
