class RenameAddressPeopleIdToPersonId < ActiveRecord::Migration[7.0]
  def change
    rename_column :addresses, :people_id, :person_id
  end
end
