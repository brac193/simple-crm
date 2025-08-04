class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reservation, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :penalty_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0
      t.string :status, null: false, default: 'pending'
      t.date :due_date, null: false
      t.datetime :paid_at

      t.timestamps
    end

    add_index :invoices, :status
    add_index :invoices, :due_date
  end
end
