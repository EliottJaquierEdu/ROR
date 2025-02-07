class CreateClassroomsPeople < ActiveRecord::Migration[8.0]
  def change
    create_table :classrooms_people, id: false do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
    end

    add_index :classrooms_people, [:classroom_id, :person_id], unique: true
  end
end
