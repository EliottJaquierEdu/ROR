class AddSubjectToCourses < ActiveRecord::Migration[8.0]
  def change
    add_reference :courses, :subject, null: false, foreign_key: true
  end
end
