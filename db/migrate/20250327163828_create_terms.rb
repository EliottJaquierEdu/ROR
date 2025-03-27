class CreateTerms < ActiveRecord::Migration[8.0]
  def change
    create_table :terms do |t|
      t.string :name, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.datetime :archived_at

      t.timestamps
    end

    add_index :terms, :archived_at
    add_index :terms, :name, unique: true
  end
end
