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
TeacherStatus.destroy_all

# Create StudentStatuses
student_status_enrolled = StudentStatus.create!(status: 'Inscrit')
student_status_graduated = StudentStatus.create!(status: 'Diplômé')

# Create TeacherStatuses
teacher_status_active = TeacherStatus.create!(status: 'Actif')
teacher_status_retired = TeacherStatus.create!(status: 'Retraité')

# Create Dean with address (inherits from Teacher)
dean = Dean.create!(
  username: 'doyen_admin',
  lastname: 'Dubois',
  firstname: 'Pierre',
  email: 'pierre.dubois@example.com',
  phone_number: '+41 79 123 45 67',
  iban: 'CH93 0076 2011 6238 5295 7',
  teacher_status: teacher_status_active,
  type: 'Dean',
  password: 'password',
  password_confirmation: 'password'
)

dean.create_address!(
  zip: 1004,
  town: 'Lausanne',
  street: 'Avenue de la Gare',
  number: '10'
)

# Create more Teachers
teachers_data = [
  {
    username: 'prof_math',
    lastname: 'Blanc',
    firstname: 'Sophie',
    email: 'sophie.blanc@example.com',
    phone_number: '+41 79 456 78 90',
    subject: 'Mathématiques'
  },
  {
    username: 'prof_francais',
    lastname: 'Müller',
    firstname: 'Jean',
    email: 'jean.muller@example.com',
    phone_number: '+41 78 567 89 01',
    subject: 'Français'
  },
  {
    username: 'prof_allemand',
    lastname: 'Weber',
    firstname: 'Anna',
    email: 'anna.weber@example.com',
    phone_number: '+41 76 678 90 12',
    subject: 'Allemand'
  },
  {
    username: 'prof_anglais',
    lastname: 'Smith',
    firstname: 'Elizabeth',
    email: 'elizabeth.smith@example.com',
    phone_number: '+41 79 789 01 23',
    subject: 'Anglais'
  },
  {
    username: 'prof_histoire',
    lastname: 'Rochat',
    firstname: 'Marc',
    email: 'marc.rochat@example.com',
    phone_number: '+41 78 890 12 34',
    subject: 'Histoire'
  },
  {
    username: 'prof_geo',
    lastname: 'Favre',
    firstname: 'Christine',
    email: 'christine.favre@example.com',
    phone_number: '+41 76 901 23 45',
    subject: 'Géographie'
  },
  {
    username: 'prof_bio',
    lastname: 'Dupont',
    firstname: 'Michel',
    email: 'michel.dupont@example.com',
    phone_number: '+41 79 012 34 56',
    subject: 'Biologie'
  },
  {
    username: 'prof_chimie',
    lastname: 'Martin',
    firstname: 'Laura',
    email: 'laura.martin@example.com',
    phone_number: '+41 78 123 45 67',
    subject: 'Chimie'
  },
  {
    username: 'prof_philo',
    lastname: 'Bonvin',
    firstname: 'Paul',
    email: 'paul.bonvin@example.com',
    phone_number: '+41 76 234 56 78',
    subject: 'Philosophie'
  },
  {
    username: 'prof_sport',
    lastname: 'Girard',
    firstname: 'David',
    email: 'david.girard@example.com',
    phone_number: '+41 79 345 67 89',
    subject: 'Éducation physique'
  }
]

teachers = teachers_data.map do |teacher_data|
  teacher = Teacher.create!(
    username: teacher_data[:username],
    lastname: teacher_data[:lastname],
    firstname: teacher_data[:firstname],
    email: teacher_data[:email],
    phone_number: teacher_data[:phone_number],
    iban: "CH#{rand(10..99)} 0076 2011 6238 5295 #{rand(0..9)}",
    teacher_status: teacher_status_active,
    type: 'Teacher',
    password: 'password',
    password_confirmation: 'password'
  )

  teacher.create_address!(
    zip: rand(1000..1008),
    town: 'Lausanne',
    street: ['Avenue d\'Ouchy', 'Rue de Bourg', 'Avenue du Léman', 'Rue Centrale', 'Avenue de Cour'].sample,
    number: "#{rand(1..50)}"
  )

  teacher
end

# Create Students (20 students for class 1M1)
students_data = [
  { firstname: 'Marie', lastname: 'Favre' },
  { firstname: 'Lucas', lastname: 'Rochat' },
  { firstname: 'Emma', lastname: 'Bernard' },
  { firstname: 'Noah', lastname: 'Dubois' },
  { firstname: 'Léa', lastname: 'Martin' },
  { firstname: 'Gabriel', lastname: 'Blanc' },
  { firstname: 'Chloé', lastname: 'Roux' },
  { firstname: 'Louis', lastname: 'Perret' },
  { firstname: 'Sofia', lastname: 'Meyer' },
  { firstname: 'Arthur', lastname: 'Bonvin' },
  { firstname: 'Eva', lastname: 'Schmid' },
  { firstname: 'Liam', lastname: 'Favre' },
  { firstname: 'Alice', lastname: 'Dupont' },
  { firstname: 'Nathan', lastname: 'Girard' },
  { firstname: 'Julie', lastname: 'Moret' },
  { firstname: 'Thomas', lastname: 'Vuille' },
  { firstname: 'Sarah', lastname: 'Rochat' },
  { firstname: 'Maxime', lastname: 'Chevalley' },
  { firstname: 'Laura', lastname: 'Pittet' },
  { firstname: 'David', lastname: 'Monney' }
]

students = students_data.map.with_index do |student_data, index|
  student = Student.create!(
    username: "etudiant_#{index + 1}",
    lastname: student_data[:lastname],
    firstname: student_data[:firstname],
    email: "#{student_data[:firstname].downcase}.#{student_data[:lastname].downcase}@example.com",
    phone_number: "+41 7#{rand(6..9)} #{rand(100..999)} #{rand(10..99)} #{rand(10..99)}",
    student_status: student_status_enrolled,
    type: 'Student',
    password: 'password',
    password_confirmation: 'password'
  )

  student.create_address!(
    zip: rand(1000..1008),
    town: ['Lausanne', 'Pully', 'Renens', 'Prilly', 'Morges'].sample,
    street: ['Avenue de la Gare', 'Rue du Lac', 'Chemin des Fleurs', 'Route de Berne', 'Avenue des Alpes'].sample,
    number: "#{rand(1..50)}"
  )

  student
end

# Create Rooms
rooms = (101..110).map { |num| Room.create!(name: "Salle #{num}") }

# Create Subjects with their respective teachers
subjects = {
  'Mathématiques' => teachers[0],
  'Français' => teachers[1],
  'Allemand' => teachers[2],
  'Anglais' => teachers[3],
  'Histoire' => teachers[4],
  'Géographie' => teachers[5],
  'Biologie' => teachers[6],
  'Chimie' => teachers[7],
  'Philosophie' => teachers[8],
  'Éducation physique' => teachers[9],
  'Physique' => teachers[0],  # Some teachers handle multiple subjects
  'Arts visuels' => teachers[1],
  'Musique' => teachers[2],
  'Informatique' => teachers[3]
}

subjects.each do |name, teacher|
  Subject.create!(name: name)
end

# Create School Class 1M1 with full schedule
class_1m1 = SchoolClass.create!(
  year: 2024,
  name: '1M1',
  room: rooms[0],
  master: teachers[0]  # Math teacher is class master
)

# Associate all students with 1M1
students.each do |student|
  class_1m1.students << student
end

# Create weekly schedule for 1M1
# Schedule template - Each period is 45 minutes with breaks
# Morning: 8:00-9:30, 9:50-11:20, 11:30-13:00
# Afternoon: 14:00-15:30, 15:45-17:15

schedule_template = {
  1 => [ # Monday
    { subject: 'Mathématiques', start_time: '08:00', end_time: '09:30' },
    { subject: 'Français', start_time: '09:50', end_time: '11:20' },
    { subject: 'Histoire', start_time: '14:00', end_time: '15:30' },
    { subject: 'Anglais', start_time: '15:45', end_time: '17:15' }
  ],
  2 => [ # Tuesday
    { subject: 'Allemand', start_time: '08:00', end_time: '09:30' },
    { subject: 'Chimie', start_time: '09:50', end_time: '11:20' },
    { subject: 'Géographie', start_time: '14:00', end_time: '15:30' },
    { subject: 'Éducation physique', start_time: '15:45', end_time: '17:15' }
  ],
  3 => [ # Wednesday
    { subject: 'Physique', start_time: '08:00', end_time: '09:30' },
    { subject: 'Mathématiques', start_time: '09:50', end_time: '11:20' },
    { subject: 'Français', start_time: '14:00', end_time: '15:30' },
    { subject: 'Arts visuels', start_time: '15:45', end_time: '17:15' }
  ],
  4 => [ # Thursday
    { subject: 'Biologie', start_time: '08:00', end_time: '09:30' },
    { subject: 'Informatique', start_time: '09:50', end_time: '11:20' },
    { subject: 'Allemand', start_time: '14:00', end_time: '15:30' },
    { subject: 'Philosophie', start_time: '15:45', end_time: '17:15' }
  ],
  5 => [ # Friday
    { subject: 'Mathématiques', start_time: '08:00', end_time: '09:30' },
    { subject: 'Musique', start_time: '09:50', end_time: '11:20' },
    { subject: 'Anglais', start_time: '14:00', end_time: '15:30' },
    { subject: 'Histoire', start_time: '15:45', end_time: '17:15' }
  ]
}

# Create courses for the entire year
term_dates = {
  'Semestre d\'automne 2024' => {
    start: DateTime.new(2024, 8, 26), # First day of autumn semester
    end: DateTime.new(2024, 12, 20)   # Last day of autumn semester
  },
  'Semestre de printemps 2025' => {
    start: DateTime.new(2025, 2, 17), # First day of spring semester
    end: DateTime.new(2025, 7, 4)     # Last day of spring semester
  }
}

# Helper to parse time string and combine with date
def combine_date_time(date, time_str)
  hours, minutes = time_str.split(':').map(&:to_i)
  date.change(hour: hours, min: minutes)
end

term_dates.each do |term_name, dates|
  # For each week in the term
  current_date = dates[:start]
  while current_date <= dates[:end]
    # For each day in the schedule template
    schedule_template.each do |day, day_schedule|
      # Calculate the date for this weekday
      weekday_date = current_date + (day - current_date.wday).days
      next if weekday_date > dates[:end]

      # Create each course for this day
      day_schedule.each do |period|
        subject = Subject.find_by(name: period[:subject])
        next unless subject # Skip if subject not found

        # Create the course with proper start and end times
        course = Course.create!(
          term: term_name,
          start_at: combine_date_time(weekday_date, period[:start_time]),
          end_at: combine_date_time(weekday_date, period[:end_time]),
          week_day: day,
          school_class: class_1m1,
          subject: subject
        )

        # Create examinations (only two per course per term)
        if rand < 0.3 # 30% chance of having an exam this week
          examination = Examination.create!(
            title: "#{['Contrôle', 'Test', 'Examen'].sample} - #{period[:subject]}",
            expected_date: combine_date_time(weekday_date, period[:start_time]),
            course: course
          )

          # Create grades for each student
          students.each do |student|
            Grade.create!(
              value: rand(3.5..6.0).round(1),
              effective_date: examination.expected_date + 1.week,
              student: student,
              examination: examination
            )
          end
        end
      end
    end

    # Move to next week
    current_date = current_date + 1.week
  end
end
