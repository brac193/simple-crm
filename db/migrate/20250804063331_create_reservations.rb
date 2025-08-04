class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :car, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :total_price

      t.timestamps
    end
  end
end
