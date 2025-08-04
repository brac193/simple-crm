class AddReturnedAtToReservations < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :returned_at, :datetime
    add_index :reservations, :returned_at
  end
end
