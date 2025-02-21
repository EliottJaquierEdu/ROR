class Teacher < Person
  validates :iban, presence: true, if: -> { self.type == "Teacher" }

  belongs_to :teacher_status, class_name: 'TeachersStatus'
end
