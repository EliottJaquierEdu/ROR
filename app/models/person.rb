class Person < ApplicationRecord
  # NOTE: This model includes an implementation of the empty? method
  # to fix an issue with Devise authentication. Without this method,
  # authentication fails with "undefined method 'empty?' for #<Student>"
  # when trying to sign in. This is related to how Rack/Devise processes
  # authentication and checks if objects are empty.

  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable

  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true

  has_and_belongs_to_many :school_classes, join_table: "people_school_classes"

  belongs_to :student_status, optional: true
  belongs_to :teacher_status, optional: true

  validates :student_status, presence: true, if: :student?
  validates :teacher_status, presence: true, if: :teacher?

  has_many :grades, foreign_key: "person_id", dependent: :destroy, class_name: "Grade"

  def full_name
    "#{firstname} #{lastname}"
  end

  def student?
    type == "Student"
  end

  def teacher?
    type == "Teacher" || type == "Dean"
  end

  def dean?
    type == "Dean"
  end

  def can_view_grade?(grade)
    return true if dean? || teacher?
    return false unless student?
    grade.person_id == id
  end

  def can_manage_resources?
    dean?
  end

  # Define empty? method to return false for Person objects
  # This prevents the NoMethodError in People::SessionsController#create
  # Devise/Rack uses this method during authentication to check if the user object is empty
  # Without this method, authentication fails with "undefined method 'empty?' for #<Student>"
  def empty?
    false
  end

  # Ensure the model responds to empty? method
  # This is needed because some parts of Rails/Rack may check respond_to?(:empty?)
  # before actually calling the method, especially during authentication
  def respond_to?(method_name, include_private = false)
    method_name.to_sym == :empty? || super
  end
  
  # String representation of a Person
  def to_s
    full_name
  end
  
  # JSON representation of a Person
  def as_json(options = {})
    super(options.merge(
      methods: [:full_name, :type],
      except: [:encrypted_password, :reset_password_token, :reset_password_sent_at]
    ))
  end
end
