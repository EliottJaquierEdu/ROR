# Clear existing data to avoid duplication
Address.delete_all
Person.delete_all
Room.delete_all
SchoolClass.delete_all
Subject.delete_all
Course.delete_all
Examination.delete_all
Grade.delete_all
StudentStatus.delete_all
TeacherStatus.delete_all

# Create StudentStatuses
student_status_enrolled = StudentStatus.create!(status: 'Enrolled')
student_status_graduated = StudentStatus.create!(status: 'Graduated')

# Create TeacherStatuses
teacher_status_active = TeacherStatus.create!(status: 'Active')
teacher_status_retired = TeacherStatus.create!(status: 'Retired')

# Create Addresses
address_1 = Address.create!(zip: 12345, town: 'Townsville', street: 'Main St', number: '1A')
address_2 = Address.create!(zip: 67890, town: 'Metropolis', street: 'Second St', number: '7B')

# Create Students
student_1 = Student.create!(
  username: 'student_one',
  lastname: 'Doe',
  firstname: 'John',
  email: 'johndoe@example.com',
  phone_number: '555-1234',
  address: address_1,
  student_status: student_status_enrolled
)
student_2 = Student.create!(
  username: 'student_two',
  lastname: 'Smith',
  firstname: 'Jane',
  email: 'janesmith@example.com',
  phone_number: '555-5678',
  address: address_2,
  student_status: student_status_graduated
)

# Create Teachers
teacher_1 = Teacher.create!(
  username: 'teacher_one',
  lastname: 'Brown',
  firstname: 'Emily',
  email: 'emilybrown@example.com',
  phone_number: '555-7890',
  address: address_1,
  iban: 'DE89370400440532013000',
  teachers_status: teacher_status_active
)
teacher_2 = Teacher.create!(
  username: 'teacher_two',
  lastname: 'Johnson',
  firstname: 'Michael',
  email: 'michaeljohnson@example.com',
  phone_number: '555-9876',
  address: address_2,
  iban: 'FR7630006000011234567890189',
  teachers_status: teacher_status_retired
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

# Create Grades
grade_1 = Grade.create!(
  value: 4.5,
  effective_date: DateTime.new(2025, 4, 16),
  student: student_1,
  examination: exam_1
)
grade_2 = Grade.create!(
  value: 3.7,
  effective_date: DateTime.new(2025, 11, 16),
  student: student_2,
  examination: exam_2
)