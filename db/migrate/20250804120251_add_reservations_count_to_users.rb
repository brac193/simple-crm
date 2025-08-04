class AddReservationsCountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :reservations_count, :integer, default: 0, null: false
    add_index :users, :reservations_count
  end
end
