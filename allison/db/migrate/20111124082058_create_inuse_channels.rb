class CreateInuseChannels < ActiveRecord::Migration
  def self.up
    create_table :inuse_channels do |t|
      t.string :name
      t.integer :user1
      t.integer :user2

      t.timestamps
    end
  end

  def self.down
    drop_table :inuse_channels
  end
end
