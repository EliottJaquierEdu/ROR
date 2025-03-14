class HomeController < ApplicationController
  before_action :authenticate_person!
  
  def index
    @students = helpers.visible_students
    @teachers = helpers.visible_teachers
    @school_classes = helpers.visible_school_classes
    @subjects = helpers.visible_subjects
    @examinations = helpers.visible_examinations.order(expected_date: :desc)
  end
end