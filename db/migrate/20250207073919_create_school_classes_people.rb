class CreateSchoolClassesPeople < ActiveRecord::Migration[8.0]
  def change
    create_table :school_classes_people, id: false do |t|
      t.references :school_class, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
    end

    add_index :school_classes_people, [:school_class_id, :person_id], unique: true
  end
end