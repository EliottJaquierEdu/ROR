class MakeStatusFieldsNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :people, :student_status_id, true
    change_column_null :people, :teacher_status_id, true
  end
end
