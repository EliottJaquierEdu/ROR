class SchoolClassStudentsController < ApplicationController
  before_action :authenticate_person!
  before_action :set_school_class
  before_action :set_student, only: [:destroy]
  before_action :authorize_manage_students

  # GET /school_classes/:school_class_id/students/new
  def new
    @available_students = Student.where.not(id: @school_class.students.pluck(:id))
  end

  # POST /school_classes/:school_class_id/students
  def create
    student_ids = params[:student_ids]

    if student_ids.present?
      @school_class.students << Student.where(id: student_ids)
      redirect_to @school_class, notice: 'Students were successfully added to the class.'
    else
      redirect_to new_school_class_student_path(@school_class), alert: 'Please select at least one student.'
    end
  end

  # DELETE /school_classes/:school_class_id/students/:id
  def destroy
    @school_class.students.delete(@student)
    redirect_to @school_class, notice: 'Student was successfully removed from the class.'
  end

  # GET /school_classes/:school_class_id/students/select_rest_class
  def select_rest_class
    @students_to_move = @school_class.students.select { |student| !student.has_sufficient_grades?(@school_class.id) }
    
    if @students_to_move.empty?
      redirect_to @school_class, notice: 'No students have insufficient grades to transfer.'
    end
  end

  # POST /school_classes/:school_class_id/students/move_to_rest
  def move_to_rest
    target_class_id = params[:target_class_id]
    
    unless target_class_id.present?
      redirect_to select_rest_class_school_class_students_path(@school_class), alert: 'Please select a target class.'
      return
    end

    target_class = SchoolClass.find(target_class_id)
    students_to_move = @school_class.students.select { |student| !student.has_sufficient_grades?(@school_class.id) }
    
    if students_to_move.any?
      # Move students to target class
      students_to_move.each do |student|
        @school_class.students.delete(student)
        target_class.students << student
      end

      redirect_to @school_class, notice: "#{students_to_move.size} student(s) with insufficient grades were transferred to #{target_class.name}."
    else
      redirect_to @school_class, notice: 'No students have insufficient grades to transfer.'
    end
  end

  private

  def set_school_class
    @school_class = SchoolClass.find(params[:school_class_id])
  end

  def set_student
    @student = Student.find(params[:id])
  end

  def authorize_manage_students
    unless helpers.can_manage_students?(@school_class)
      redirect_to @school_class, alert: 'You are not authorized to manage students in this class.'
    end
  end
end
