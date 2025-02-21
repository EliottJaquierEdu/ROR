class Course < ApplicationRecord
  belongs_to :school_class
  belongs_to :subject
  has_many :examinations

  validates :term, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :week_day, presence: true, inclusion: { in: 0..6 } # Ensures it's a valid weekday
end
