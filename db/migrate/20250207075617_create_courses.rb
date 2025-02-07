class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :term, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.integer :week_day, null: false
      t.references :classroom, null: false, foreign_key: true

      t.timestamps
    end
  end
end
