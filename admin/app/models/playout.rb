class Playout
  MILISECOND = 1000

  def initialize(channel, current_epoch=Time.now.to_i)
    @current_epoch = current_epoch
    @channel = channel

    possible_current_schedule = @channel.schedules.find {|s| s.airing_time.to_i * MILISECOND + s.video.duration_ms > @current_epoch.to_i * MILISECOND}
    current_index = possible_current_schedule.video_index

    # picking previous, current + two future clips
    @playout_schedules = @channel.schedules.select {|s| s.video_index >= current_index - 1 and s.video_index <= current_index + 2 }
  end

  def to_hash
    {
      playlistType: "live",
      discontinuity: true,
      segmentDuration: @channel.segment_duration_ms,
      currentTime: @current_epoch.to_i * MILISECOND,
      initialClipIndex: initialClipIndex, # initial clip index (this works similar to media sequence), it's going to grow
      initialSegmentIndex: initialSegmentIndex, # initial segment index (the same as before but in segment level)
      clipTimes: @playout_schedules.map {|p| p.airing_time.to_i * MILISECOND}, # epoch start of each clip in ms
      clipSegments: @playout_schedules.map{|p| p.segments_count}, # number of segments per clip
      durations: @playout_schedules.map{|p| p.video.duration_ms}, # durations in ms per clip
      sequences: sequences
    }
  end

  def initialClipIndex
    @playout_schedules.first.video_index
  end

  def initialSegmentIndex
    previous_schedules = @channel.schedules.select {|s| s.video_index < initialClipIndex}
    return 1 if previous_schedules.empty?
    previous_schedules.map {|s| s.segments_count}.sum + 1
  end

  def sequences
    abr_length = @playout_schedules.first.video.renditions.length
    (0...abr_length).map do |abr_index|
      {clips: @playout_schedules.map {|s| {type: "source", path: s.video.renditions[abr_index].path}}}
    end
  end
end

