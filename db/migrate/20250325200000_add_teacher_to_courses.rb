class AddTeacherToCourses < ActiveRecord::Migration[8.0]
  def change
    add_reference :courses, :teacher, null: false, foreign_key: { to_table: :people }
  end
end
