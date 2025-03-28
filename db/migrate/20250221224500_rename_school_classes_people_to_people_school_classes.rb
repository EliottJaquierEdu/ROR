class RenameSchoolClassesPeopleToPeopleSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    rename_table :school_classes_people, :people_school_classes
  end
end
