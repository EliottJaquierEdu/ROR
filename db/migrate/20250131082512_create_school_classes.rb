class CreateSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :school_classes do |t|
      t.integer :year
      t.string :name
      t.references :room, null: false, foreign_key: true
      t.integer :master

      t.timestamps
    end
  end
end
