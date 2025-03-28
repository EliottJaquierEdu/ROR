class AddIbanToTeachers < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :iban, :string
  end
end
