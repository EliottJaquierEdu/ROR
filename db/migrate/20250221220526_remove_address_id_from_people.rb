class RemoveAddressIdFromPeople < ActiveRecord::Migration[8.0]
  def change
    remove_column :people, :address_id, :integer
  end
end
