# Clear existing data to avoid duplication
Grade.destroy_all
Examination.destroy_all
Course.destroy_all
SchoolClass.destroy_all
Subject.destroy_all
Address.destroy_all
Person.destroy_all
Room.destroy_all
StudentStatus.destroy_all
TeachersStatus.destroy_all

# Create StudentStatuses
student_status_enrolled = StudentStatus.create!(status: 'Enrolled')
student_status_graduated = StudentStatus.create!(status: 'Graduated')

# Create TeacherStatuses
teacher_status_active = TeachersStatus.create!(status: 'Active')
teacher_status_retired = TeachersStatus.create!(status: 'Retired')

# Create Students with their addresses
student_1 = Student.create!(
  username: 'student_one',
  lastname: 'Doe',
  firstname: 'John',
  email: 'johndoe@example.com',
  phone_number: '555-1234',
  student_status: student_status_enrolled,
  type: 'Student'
)

student_1.create_address!(
  zip: 12345,
  town: 'Townsville',
  street: 'Main St',
  number: '1A'
)

student_2 = Student.create!(
  username: 'student_two',
  lastname: 'Smith',
  firstname: 'Jane',
  email: 'janesmith@example.com',
  phone_number: '555-5678',
  student_status: student_status_graduated,
  type: 'Student'
)

student_2.create_address!(
  zip: 67890,
  town: 'Metropolis',
  street: 'Second St',
  number: '7B'
)

# Create Teachers with their addresses
teacher_1 = Teacher.create!(
  username: 'teacher_one',
  lastname: 'Brown',
  firstname: 'Emily',
  email: 'emilybrown@example.com',
  phone_number: '555-7890',
  iban: 'DE89370400440532013000',
  teacher_status: teacher_status_active,
  type: 'Teacher'
)

teacher_1.create_address!(
  zip: 54321,
  town: 'Teacherville',
  street: 'School St',
  number: '5C'
)

teacher_2 = Teacher.create!(
  username: 'teacher_two',
  lastname: 'Johnson',
  firstname: 'Michael',
  email: 'michaeljohnson@example.com',
  phone_number: '555-9876',
  iban: 'FR7630006000011234567890189',
  teacher_status: teacher_status_retired,
  type: 'Teacher'
)

teacher_2.create_address!(
  zip: 98765,
  town: 'Educity',
  street: 'Learning Ave',
  number: '3D'
)

# Create Rooms
room_1 = Room.create!(name: 'Room A')
room_2 = Room.create!(name: 'Room B')

# Create School Classes
school_class_1 = SchoolClass.create!(
  uid: 'SC101',
  name: 'Class A',
  room: room_1,
  master: teacher_1
)

school_class_2 = SchoolClass.create!(
  uid: 'SC102',
  name: 'Class B',
  room: room_2,
  master: teacher_2
)

# Associate Students with School Classes
school_class_1.students << student_1
school_class_2.students << student_2

# Create Subjects
subject_1 = Subject.create!(name: 'Mathematics')
subject_2 = Subject.create!(name: 'Science')

# Create Courses
course_1 = Course.create!(
  term: 'Spring 2025',
  start_at: DateTime.new(2025, 3, 1),
  end_at: DateTime.new(2025, 6, 1),
  week_day: 1,
  school_class: school_class_1,
  subject: subject_1
)

course_2 = Course.create!(
  term: 'Fall 2025',
  start_at: DateTime.new(2025, 9, 1),
  end_at: DateTime.new(2025, 12, 1),
  week_day: 3,
  school_class: school_class_2,
  subject: subject_2
)

# Create Examinations
exam_1 = Examination.create!(
  title: 'Midterm Exam',
  expected_date: DateTime.new(2025, 4, 15),
  course: course_1
)

exam_2 = Examination.create!(
  title: 'Final Exam',
  expected_date: DateTime.new(2025, 11, 15),
  course: course_2
)

Grade.create!(
  value: 4.5,
  effective_date: DateTime.new(2025, 4, 16),
  student: student_1,  # Use 'student' as defined in Grade model
  examination: exam_1
)

Grade.create!(
  value: 3.7,
  effective_date: DateTime.new(2025, 11, 16),
  student: student_2,  # Use 'student' as defined in Grade model
  examination: exam_2
)