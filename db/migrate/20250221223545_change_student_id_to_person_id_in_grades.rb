class ChangeStudentIdToPersonIdInGrades < ActiveRecord::Migration[8.0]
  def change
    rename_column :grades, :student_id, :person_id
  end
end
