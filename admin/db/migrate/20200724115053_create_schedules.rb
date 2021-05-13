class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.integer :airing_epoch_ms
      t.integer :video_index
      t.integer :segments_count
      t.references :channel, foreign_key: true

      t.timestamps
    end
  end
end
