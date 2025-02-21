class Person < ApplicationRecord
  has_one :address
  accepts_nested_attributes_for :address, allow_destroy: true

  has_and_belongs_to_many :school_classes

  belongs_to :student_status, optional: true
  validates :student_status, presence: true, if: :student?

  def full_name
    "#{firstname} #{lastname}"
  end

  private

  def student?
    type == "Student"
  end
end
