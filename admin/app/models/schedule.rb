class Schedule < ApplicationRecord
  belongs_to :channel
  belongs_to :video

  validates :channel, presence: true
  validates :video, presence: true
  validates :airing_time, presence: true
  validates :segments_count, presence: true, numericality: {greater_than_or_equal_to: 1}
  validates :video_index, presence: true, numericality: {greater_than_or_equal_to: 1}

  # maybe all this must be into a transaction
  before_validation do
    if !self.channel.present? or !self.video.present?
      next
    end
    # assuming defaults - maybe count cache at channel
    if channel.schedules.empty?
      self.video_index = 1
      self.airing_time = Time.current() if !self.airing_time.present?
    else
      last_schedule = channel.schedules.last # maybe re-sort by date?
      self.video_index = last_schedule.video_index + 1
      # automatically fit next video into the schedule
      self.airing_time = last_schedule.airing_time + (last_schedule.video.duration_ms/1000) if !self.airing_time.present?
    end

    # number of segments given the segment duration
    # seg_dur = 5 * 1000 (5s in ms)
    # tot_dur = 15.8 * 1000 (15.8s in ms)
    # ceil(tot_dur/seg_dur) = 4 segments
    self.segments_count = (video.duration_ms.to_f / channel.segment_duration_ms.to_f).ceil
  end

  def to_s
    "[#{channel.label}] - <#{video_index}> - #{video.label} - #{video.duration_ms/1000/60} mins long - starts at #{airing_time}"
  end
end
