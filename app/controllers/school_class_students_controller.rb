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
    @students_to_promote = @school_class.students.select { |student| student.has_sufficient_grades?(@school_class.id) }
    @students_to_repeat = @school_class.students.reject { |student| student.has_sufficient_grades?(@school_class.id) }
    
    if @students_to_promote.empty? && @students_to_repeat.empty?
      redirect_to @school_class, notice: 'No students to process.'
    end
  end

  # POST /school_classes/:school_class_id/students/move_to_rest
  def move_to_rest
    target_class_id = params[:target_class_id]
    repeat_class_id = params[:repeat_class_id]
    
    unless target_class_id.present? || repeat_class_id.present?
      redirect_to select_rest_class_school_class_students_path(@school_class), 
                  alert: 'Please select at least one target class.'
      return
    end

    students_to_promote = @school_class.students.select { |student| student.has_sufficient_grades?(@school_class.id) }
    students_to_repeat = @school_class.students.reject { |student| student.has_sufficient_grades?(@school_class.id) }
    
    success_messages = []
    
    if target_class_id.present? && students_to_promote.any?
      target_class = SchoolClass.find(target_class_id)
      students_to_promote.each do |student|
        target_class.students << student unless target_class.students.include?(student)
      end
      success_messages << "#{students_to_promote.size} student(s) were promoted to #{target_class.name}."
    end

    if repeat_class_id.present? && students_to_repeat.any?
      repeat_class = SchoolClass.find(repeat_class_id)
      students_to_repeat.each do |student|
        repeat_class.students << student unless repeat_class.students.include?(student)
      end
      success_messages << "#{students_to_repeat.size} student(s) were moved to repeat class #{repeat_class.name}."
    end

    if success_messages.any?
      redirect_to @school_class, notice: success_messages.join(' ')
    else
      redirect_to @school_class, notice: 'No students were processed.'
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
