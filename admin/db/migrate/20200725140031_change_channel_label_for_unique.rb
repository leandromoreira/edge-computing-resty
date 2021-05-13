class ChangeChannelLabelForUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :channels, :label, unique: true
  end
end
