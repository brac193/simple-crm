class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    execute <<-SQL
      CREATE TYPE user_role AS ENUM('admin', 'user');
    SQL
    add_column :users, :role, :user_role, default: "user", null: false
    add_index :users, :role
  end
end
