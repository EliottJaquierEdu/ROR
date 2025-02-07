class CreateGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :grades do |t|
      t.decimal :value, precision: 5, scale: 2, null: false
      t.datetime :effective_date, null: false
      t.references :student, null: false, foreign_key: { to_table: :people }
      t.references :examination, null: false, foreign_key: true

      t.timestamps
    end
  end
end
