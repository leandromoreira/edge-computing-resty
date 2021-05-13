class RemoveAiringEpochMsFromSchedules < ActiveRecord::Migration[5.2]
  def change
    remove_column :schedules, :airing_epoch_ms, :integer
  end
end
