class CreateSchoolClassesPeople < ActiveRecord::Migration[8.0]
  def change
    create_table :scool_classes_people, id: false do |t|
      t.references :school_class, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
    end

    add_index :scool_classes_people, [:scool_class_id, :person_id], unique: true
  end
end
