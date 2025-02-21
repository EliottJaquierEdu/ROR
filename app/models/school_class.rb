class SchoolClass < ApplicationRecord
  belongs_to :room
  belongs_to :master, class_name: "Person", foreign_key: "master"
  has_and_belongs_to_many :students, class_name: "Person", join_table: "school_classes_people"

  has_many :courses
end
