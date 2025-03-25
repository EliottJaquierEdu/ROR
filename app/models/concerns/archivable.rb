module Archivable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(archived_at: nil) }
    scope :archived, -> { where.not(archived_at: nil) }

    # Default scope to only show active records
    default_scope { active }
  end

  def archived?
    archived_at.present?
  end

  def active?
    !archived?
  end

  def archive!
    transaction do
      update!(archived_at: Time.current)
      archive_dependencies if respond_to?(:archive_dependencies)
    end
  end

  def unarchive!
    transaction do
      update!(archived_at: nil)
      unarchive_dependencies if respond_to?(:unarchive_dependencies)
    end
  end

  # Class methods
  class_methods do
    def without_default_scope
      unscoped
    end
  end
end
