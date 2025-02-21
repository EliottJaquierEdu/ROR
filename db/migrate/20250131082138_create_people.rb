class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :username
      t.string :lastname
      t.string :firstname
      t.string :email
      t.string :phone_number
      t.references :status, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.string :type

      t.timestamps
    end
    add_index :people, :email, unique: true
  end
end
