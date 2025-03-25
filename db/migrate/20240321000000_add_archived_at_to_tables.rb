class AddArchivedAtToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :grades, :archived_at, :datetime
    add_column :examinations, :archived_at, :datetime
    add_column :courses, :archived_at, :datetime
    add_column :school_classes, :archived_at, :datetime
    add_column :subjects, :archived_at, :datetime
    add_column :addresses, :archived_at, :datetime
    add_column :people, :archived_at, :datetime
    add_column :rooms, :archived_at, :datetime
    add_column :student_statuses, :archived_at, :datetime
    add_column :teacher_statuses, :archived_at, :datetime
    add_column :people_school_classes, :archived_at, :datetime

    # Add indexes for better query performance
    add_index :grades, :archived_at
    add_index :examinations, :archived_at
    add_index :courses, :archived_at
    add_index :school_classes, :archived_at
    add_index :subjects, :archived_at
    add_index :addresses, :archived_at
    add_index :people, :archived_at
    add_index :rooms, :archived_at
    add_index :student_statuses, :archived_at
    add_index :teacher_statuses, :archived_at
    add_index :people_school_classes, :archived_at
  end
end
