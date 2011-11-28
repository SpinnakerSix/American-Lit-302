class CreateUserLevels < ActiveRecord::Migration
  def self.up
    create_table :user_levels do |t|
      t.string :ip
      t.integer :user_level

      t.timestamps
    end
  end

  def self.down
    drop_table :user_levels
  end
end
