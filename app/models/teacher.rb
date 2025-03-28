class Teacher < Person
  include Teachable

  belongs_to :teacher_status, optional: true
  validates :teacher_status, presence: true, if: -> { self.type == "Teacher" || self.type == "Dean" }
  validates :iban, presence: true

  has_many :courses, foreign_key: 'teacher_id'
  has_many :subjects, -> { distinct }, through: :courses

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
