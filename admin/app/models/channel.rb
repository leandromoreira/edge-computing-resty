class Channel < ApplicationRecord
  validates :label, presence: true, uniqueness: true
  validates :segment_duration_ms, presence: true, numericality: {greater_than_or_equal_to: 1000}
  has_many :schedules

  def to_s
    "[#{label}] - #{segment_duration_ms/1000} s"
  end

  def as_json(options={})
    super({
      only: [:label, :segment_duration_ms],
      include: {
        schedules: {
          only: [:video_index, :airing_time, :segments_count],
          include: {
            video: {
              only: [:label, :duration_ms],
              include: {renditions: {only: [:label, :path]}}
            }
          }
        }
      }
    }.merge options)
  end
end
