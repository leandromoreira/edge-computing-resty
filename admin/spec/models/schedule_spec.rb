require 'rails_helper'

RSpec.describe Schedule, type: :model do
  it "defines the video index" do
    channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
    renditions = [Rendition.new(label: "r", path: "p")]
    video = Video.new renditions: renditions, label: "v1", duration_ms: 30 * 1000

    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    expect(schedule.video_index).to eq(1)
  end

  it "defines the segment count for duration multiple of segment size" do
    channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
    renditions = [Rendition.new(label: "r", path: "p")]
    video = Video.new renditions: renditions, label: "v1", duration_ms: 30 * 1000

    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    expect(schedule.segments_count).to eq(6) # 30*1000/5*1000
  end

  it "defines the segment count for duration not multiple of segment size" do
    channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
    renditions = [Rendition.new(label: "r", path: "p")]
    video = Video.new renditions: renditions, label: "v1", duration_ms: 32.4 * 1000

    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    expect(schedule.segments_count).to eq(7) # 6 segments of 5s long plus one of 2.4s
  end

  it "auto increases the video index" do
    channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
    renditions = [Rendition.new(label: "r", path: "p")]
    video = Video.new renditions: renditions, label: "v1", duration_ms: 30 * 1000

    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    channel.schedules << schedule
    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    expect(schedule.video_index).to eq(2)
  end

  it "defines the airing time if it's not set" do
    channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
    renditions = [Rendition.new(label: "r", path: "p")]
    video = Video.new renditions: renditions, label: "v1", duration_ms: 30 * 1000

    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    expect(schedule.airing_time.to_i).to be >= Time.now.to_i
  end

  it "fits the airing time using the previous" do
    channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
    renditions = [Rendition.new(label: "r", path: "p")]
    video = Video.new renditions: renditions, label: "v1", duration_ms: 30 * 1000

    schedule = Schedule.new video: video, channel: channel
    schedule.valid?
    previous_airing_time = schedule.airing_time.to_i

    channel.schedules << schedule
    schedule = Schedule.new video: video, channel: channel
    schedule.valid?

    expect(schedule.airing_time.to_i).to eq(previous_airing_time + 30) # the next clip will be previous.airing_time + previous.duration
  end
end
