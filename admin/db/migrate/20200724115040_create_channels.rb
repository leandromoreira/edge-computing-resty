class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :label
      t.integer :segment_duration_ms

      t.timestamps
    end
  end
end
