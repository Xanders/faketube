class CreateVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :videos do |t|
      t.attachment :original
      t.attachment :processed
      t.attachment :thumbnail
      t.integer :time

      t.timestamps
    end
  end
end
