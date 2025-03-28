class RemoveWeekDayFromCourses < ActiveRecord::Migration[7.1]
  def change
    remove_column :courses, :week_day, :integer
  end
end
