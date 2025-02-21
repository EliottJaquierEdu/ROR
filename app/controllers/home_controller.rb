class HomeController < ApplicationController
  def index
    @people = Person.all # List all people
    @students = Student.all # List all students
    @teachers = Teacher.all # List all teachers
  end
end