class Video < ApplicationRecord
  has_many :renditions, dependent: :destroy
  accepts_nested_attributes_for :renditions, allow_destroy: true

  validates :label, presence: true
  validates :duration_ms, presence: true, numericality: {greater_than_or_equal_to: 1}
  validates :renditions, length: { minimum: 1, message: "You must add at least one rendintion" }
  # actually it also needs to have the same amount of rendintion in all schedule
  # they need to be ordered so the kaltura won't mix them
  # or using label to group?!

  def to_s
    "#{label} - #{duration_ms/1000/60} m"
  end
end
