class AddReservationsCountToCars < ActiveRecord::Migration[8.0]
  def change
    add_column :cars, :reservations_count, :integer, default: 0, null: false
    add_index :cars, :reservations_count
  end
end
