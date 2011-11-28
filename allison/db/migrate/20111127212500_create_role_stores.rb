class CreateRoleStores < ActiveRecord::Migration
  def self.up
    create_table :role_stores do |t|
      t.string :role1
      t.string :role2
      t.string :user1
      t.string :user2

      t.timestamps
    end
  end

  def self.down
    drop_table :role_stores
  end
end
