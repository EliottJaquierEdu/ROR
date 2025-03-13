class Person < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable

  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true

  has_and_belongs_to_many :school_classes, join_table: "people_school_classes"

  belongs_to :student_status, optional: true
  belongs_to :teacher_status, optional: true

  validates :student_status, presence: true, if: :student?
  validates :teacher_status, presence: true, if: :teacher?

  has_many :grades, foreign_key: "person_id", dependent: :destroy, class_name: "Grade"

  def full_name
    "#{firstname} #{lastname}"
  end

  private

  def student?
    type == "Student"
  end

  def teacher?
    type == "Teacher"
  end
end
