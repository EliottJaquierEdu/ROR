class Teacher < Person
  validates :iban, presence: true, if: -> { self.type == "Teacher" }

  belongs_to :teachers_status
end
