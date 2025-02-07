class AddTypeToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :type, :string

    add_index :people, :type
  end
end
