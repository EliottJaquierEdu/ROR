class Examination < ApplicationRecord
  belongs_to :course
  has_many :grades, dependent: :destroy

  validates :title, presence: true
  validates :expected_date, presence: true
end
