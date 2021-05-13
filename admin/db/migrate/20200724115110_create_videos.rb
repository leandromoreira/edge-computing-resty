class CreateVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :videos do |t|
      t.string :label
      t.integer :duration_ms
      t.references :schedule, foreign_key: true

      t.timestamps
    end
  end
end
