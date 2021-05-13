class DropScheduleIdFromVideos < ActiveRecord::Migration[5.2]
  def change
    remove_column :videos, :schedule_id
  end
end
