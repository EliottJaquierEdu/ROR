class CreateExaminations < ActiveRecord::Migration[8.0]
  def change
    create_table :examinations do |t|
      t.string :title
      t.datetime :expected_date
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
