class Teacher < Person
  belongs_to :teacher_status, optional: true
  validates :teacher_status, presence: true, if: -> { self.type == "Teacher" || self.type == "Dean" }
  validates :iban, presence: true
  
  # String representation of a Teacher
  def to_s
    "Teacher: #{full_name}"
  end
  
  # JSON representation of a Teacher
  def as_json(options = {})
    super(options.merge(
      include: { teacher_status: { only: [:id, :status] } },
      except: [:iban] # Don't expose sensitive banking information
    ))
  end
end
