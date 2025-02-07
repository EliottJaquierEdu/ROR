class Classroom < ApplicationRecord
  belongs_to :moment
  belongs_to :room
  belongs_to :sector
  belongs_to :master, class_name: "Person", foreign_key: "master"
  has_and_belongs_to_many :students, class_name: "Student", join_table: "classrooms_people"

  has_many :courses
end
