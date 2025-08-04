class CreateCars < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      CREATE TYPE car_type AS ENUM('small', 'city', 'suv');
    SQL
    create_table :cars do |t|
      t.string :make
      t.string :model
      t.integer :year
      t.string :license_plate
      t.decimal :daily_rate

      t.timestamps
    end
    add_column :cars, :car_type, :car_type, default: "small", null: false
    add_index :cars, :car_type
  end

  def down
    remove_column :cars, :car_type
    drop_table :cars
    execute <<-SQL
      DROP TYPE car_type;
    SQL
  end
end
