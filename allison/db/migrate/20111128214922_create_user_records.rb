class CreateUserRecords < ActiveRecord::Migration
  def self.up
    create_table :user_records do |t|
      t.string :ip
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_records
  end
end
