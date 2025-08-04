class AddUpcomingAndPastReservationsCountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :upcoming_reservations_count, :integer, default: 0, null: false
    add_column :users, :past_reservations_count, :integer, default: 0, null: false
    add_index :users, :upcoming_reservations_count
    add_index :users, :past_reservations_count
  end
end
