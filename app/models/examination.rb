class Examination < ApplicationRecord
  belongs_to :course
  has_many :grades, dependent: :destroy

  validates :title, presence: true
  validates :expected_date, presence: true
  
  # String representation of an Examination
  def to_s
    "#{title} (#{expected_date&.strftime('%Y-%m-%d')})"
  end
  
  # JSON representation of an Examination
  def as_json(options = {})
    super(options.merge(
      include: { course: { only: [:id, :term, :subject_id] } }
    ))
  end
end
