class RenameTeachersStatusesToTeacherStatuses < ActiveRecord::Migration[8.0]
  def change
    rename_table :teachers_statuses, :teacher_statuses
  end
end
