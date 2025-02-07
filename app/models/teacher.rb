class Teacher < Person
  validates :iban, presence: true

  belongs_to :teachers_status
end
