class CreateFreeChannels < ActiveRecord::Migration
  def self.up
    create_table :free_channels do |t|
      t.integer :user1
      t.string :role1

      t.timestamps
    end
  end

  def self.down
    drop_table :free_channels
  end
end
