class SchoolClass < ApplicationRecord
  belongs_to :room
  belongs_to :master, class_name: "Person", foreign_key: "master"
  has_and_belongs_to_many :students, class_name: "Student", join_table: "scool_classes_people"

  has_many :courses
end
