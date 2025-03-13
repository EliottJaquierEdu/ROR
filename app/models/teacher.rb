class Teacher < Person
  belongs_to :teacher_status, optional: true
  validates :teacher_status, presence: true, if: -> { self.type == "Teacher" || self.type == "Dean" }
  validates :iban, presence: true
end
