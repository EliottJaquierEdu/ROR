class RenamePersonTypeToTypeInPeople < ActiveRecord::Migration[8.0]
  def change
    rename_column :people, :person_type, :type
  end
end