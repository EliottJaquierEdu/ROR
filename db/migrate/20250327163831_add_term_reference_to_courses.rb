class AddTermReferenceToCourses < ActiveRecord::Migration[8.0]
  def up
    # First, create a default term for existing courses
    execute <<-SQL
      INSERT INTO terms (name, start_at, end_at, created_at, updated_at)
      SELECT DISTINCT term, start_at, end_at, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM courses
      WHERE term IS NOT NULL
      ON CONFLICT (name) DO NOTHING
    SQL

    # Add the term_id column
    add_reference :courses, :term, foreign_key: true

    # Update the term_id for existing courses
    execute <<-SQL
      UPDATE courses
      SET term_id = terms.id
      FROM terms
      WHERE courses.term = terms.name
    SQL

    # Remove the old term column
    remove_column :courses, :term
  end

  def down
    add_column :courses, :term, :string

    # Restore the term data
    execute <<-SQL
      UPDATE courses
      SET term = terms.name
      FROM terms
      WHERE courses.term_id = terms.id
    SQL

    remove_reference :courses, :term
  end
end
