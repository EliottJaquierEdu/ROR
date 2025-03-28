class Room < ApplicationRecord
  include Archivable

  has_many :school_classes

  validates :name, presence: true, uniqueness: true

  # String representation of a Room
  def to_s
    name
  end

  # JSON representation of a Room
  def as_json(options = {})
    super(options.merge(
      methods: [:class_count]
    ))
  end

  # Helper method to get the number of classes
  def class_count
    school_classes.count
  end

  private

  def archive_dependencies
    school_classes.each(&:archive!)
  end

  def unarchive_dependencies
    # Don't automatically unarchive school_classes as they might have been archived for other reasons
  end
end
