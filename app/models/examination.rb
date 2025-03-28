class Examination < ApplicationRecord
  include Archivable

  belongs_to :course
  has_many :grades, dependent: :destroy

  validates :title, presence: true

  # String representation of an Examination
  def to_s
    title
  end

  # JSON representation of an Examination
  def as_json(options = {})
    super(options.merge(
      include: { course: { only: [:id, :term, :subject_id] } }
    ))
  end

  private

  def archive_dependencies
    grades.each(&:archive!)
  end

  def unarchive_dependencies
    # Don't automatically unarchive grades as they might have been archived for other reasons
  end
end
