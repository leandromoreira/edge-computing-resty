class PlayoutController < ApplicationController
  def show
    begin
      channel = Channel.includes(schedules: [video: [:renditions]]).find_by(label: params[:id])
      playout = Playout.new channel, Time.now

      render json: playout.to_hash
    rescue StandardError => e
      render json: {
        error: e.to_s
      }, status: :not_found
    end
  end
end
