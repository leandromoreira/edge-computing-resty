class ChangeAiringTimeToDatetime < ActiveRecord::Migration[5.2]
  def change
    change_column :schedules, :airing_time, :datetime
  end
end
