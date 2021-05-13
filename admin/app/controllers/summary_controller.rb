class SummaryController < ApplicationController
  def show
    channel = Channel.includes(schedules: [video: [:renditions]]).find_by(label: params[:id])
    channel_label = channel.label

    @timeline = channel.schedules.map do |s|
      "['#{channel_label}', '#{s.video.label}', new Date(#{s.airing_time.to_i * 1000}) , new Date(#{s.airing_time.to_i * 1000 + s.video.duration_ms})],"
    end.join[0...-1]

    @timeline = @timeline.html_safe
  end
end
