class SchoolClass < ApplicationRecord
  belongs_to :room
  belongs_to :master, class_name: "Person"
  has_and_belongs_to_many :students, class_name: "Person", join_table: "people_school_classes"

  has_many :courses
end
