class CreateRenditions < ActiveRecord::Migration[5.2]
  def change
    create_table :renditions do |t|
      t.string :label
      t.string :path
      t.references :video, foreign_key: true

      t.timestamps
    end
  end
end
