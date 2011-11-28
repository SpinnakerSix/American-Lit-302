class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :channel
      t.string :user1
      t.string :user2
      t.string :role1
      t.string :role2

      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
