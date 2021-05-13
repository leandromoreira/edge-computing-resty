require 'rails_helper'

# creation of automatic schedules containing videos of 30s long duration
def create_playout(number_of_schedules=1, first_schedule_airing_time=Time.now, current_epoch=Time.now + 2, number_of_renditions=1)
  channel = Channel.new label: "channel", segment_duration_ms: 5 * 1000
  renditions = (0...number_of_renditions).map {|r| Rendition.new label: "r#{r}", path: "p#{r}"}
  video = Video.new renditions: renditions, label: "v1", duration_ms: 30 * 1000

  current_schedule = first_schedule_airing_time
  (0...number_of_schedules).each do |sch|
    schedule = Schedule.new channel: channel, video: video, airing_time: current_schedule
    schedule.valid? # forcing pre-hook to set default before adding to the channel
    channel.schedules << schedule
    current_schedule = current_schedule + 30
  end

  Playout.new channel, current_epoch
end

RSpec.describe Playout, type: :model do

  context "#sequences" do
    it "creates a single rendition sequence with a single clip" do
      playout = create_playout

      expect(playout.to_hash[:sequences][0][:clips].length).to eq(1)
      expect(playout.to_hash[:sequences].length).to eq(1)
    end

    it "creates a single rendition sequence with multiple clips" do
      playout = create_playout(3)

      expect(playout.to_hash[:sequences][0][:clips].length).to eq(3)
      expect(playout.to_hash[:sequences].length).to eq(1)
    end

    it "creates a multiple renditions sequence with multiple clips" do
      playout = create_playout(6, Time.now, Time.now+2, 7)

      expect(playout.to_hash[:sequences].length).to eq(7)
      expect(playout.to_hash[:sequences][0][:clips].length).to eq(3) # we take previous, current + two future schedules only
      expect(playout.to_hash[:sequences][6][:clips].length).to eq(3) # we take previous, current + two future schedules only
    end

    it "creates a multiple renditions sequence with multiple clips starting in the future" do
      playout = create_playout(6, Time.now, Time.now+32, 7)

      expect(playout.to_hash[:sequences].length).to eq(7)
      expect(playout.to_hash[:sequences][0][:clips].length).to eq(4) # we take previous, current + two future schedules only
      expect(playout.to_hash[:sequences][6][:clips].length).to eq(4) # we take previous, current + two future schedules only
    end
  end

  context "timing and indexes" do
    now = Time.now
    test_cases = [
      ########################################################
      # * = now
      #
      #  [clip 1]
      #  ...*........................................ (time)
      #
      ########################################################
      {
        name: "for a single schedule",
        playout: create_playout(1,now,now+2),
        clip_index: 1,
        segments_index: 1,
        times: [now.to_i*1000],
        segments_count: [6],
        segments_duration: [30*1000],
      },
      ########################################################
      # * = now
      #
      #  [clip 1][clip 2]
      #  ...*........................................ (time)
      #
      ########################################################
      {
        name: "for two schedules",
        playout: create_playout(2,now,now+2),
        clip_index: 1,
        segments_index: 1,
        times: [now.to_i*1000, now.to_i*1000 + 30*1000],
        segments_count: [6,6],
        segments_duration: [30*1000,30*1000],
      },
      ########################################################
      # * = now
      #
      #  [clip 1][clip 2][clip 3]
      #  ...........*................................. (time)
      #
      ########################################################
      {
        name: "for three schedules, starting at the second",
        playout: create_playout(3,now,now+32),
        clip_index: 1,
        segments_index: 1,
        times: [now.to_i*1000, now.to_i*1000 + 30*1000, now.to_i*1000 + 2*30*1000],
        segments_count: [6,6,6],
        segments_duration: [30*1000,30*1000,30*1000],
      },
      ########################################################
      # * = now
      #
      #  [clip 1][clip 2][clip 3][clip 4]
      #  ...................*......................... (time)
      #
      ########################################################
      {
        name: "for three schedules, discarting the first one",
        playout: create_playout(4,now,now+62),
        clip_index: 2,
        segments_index: 7,
        times: [now.to_i*1000 + 30*1000, now.to_i*1000 + 2*30*1000, now.to_i*1000 + 3*30*1000],
        segments_count: [6,6,6],
        segments_duration: [30*1000,30*1000,30*1000],
      },
    ]

    test_cases.each do |test_case|
      it "creates a playout #{test_case[:name]}" do
        playout = test_case[:playout]

        expect(playout.to_hash[:initialClipIndex]).to eq(test_case[:clip_index])
        expect(playout.to_hash[:initialSegmentIndex]).to eq(test_case[:segments_index])
        expect(playout.to_hash[:clipTimes]).to eq(test_case[:times])
        expect(playout.to_hash[:clipSegments]).to eq(test_case[:segments_count])
        expect(playout.to_hash[:durations]).to eq(test_case[:segments_duration])
      end
    end
  end
end
