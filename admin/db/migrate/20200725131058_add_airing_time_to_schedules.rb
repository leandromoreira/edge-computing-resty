class AddAiringTimeToSchedules < ActiveRecord::Migration[5.2]
  def change
    add_column :schedules, :airing_time, :date
  end
end
