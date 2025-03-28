class RemoveExpectedDateFromExaminations < ActiveRecord::Migration[8.0]
  def change
    remove_column :examinations, :expected_date, :datetime
  end
end
