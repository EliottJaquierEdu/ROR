class Term < ApplicationRecord
  include Archivable

  has_many :courses, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_after_start_at

  def to_s
    name
  end

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?

    if end_at <= start_at
      errors.add(:end_at, "must be after start_at")
    end
  end
end 