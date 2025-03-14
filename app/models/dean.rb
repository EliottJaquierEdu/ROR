class Dean < Teacher
  # Dean inherits all Teacher attributes and validations
  
  # String representation of a Dean
  def to_s
    "Dean: #{full_name}"
  end
  
  # JSON representation of a Dean
  def as_json(options = {})
    super(options.merge(
      methods: [:can_manage_resources]
    ))
  end
end
