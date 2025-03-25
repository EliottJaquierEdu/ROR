class HomeController < ApplicationController
  before_action :authenticate_person!

  def index
    @students = helpers.visible_students
    @teachers = helpers.visible_teachers.includes(courses: [:subject, :school_class, :examinations])
    @school_classes = helpers.visible_school_classes
    @subjects = helpers.visible_subjects
    @examinations = helpers.visible_examinations.includes(:course).order(created_at: :desc).limit(5)
  end
end
