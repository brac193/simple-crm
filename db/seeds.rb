# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample cars
puts "Creating sample cars..."

cars_data = [
  { make: "Toyota", model: "Corolla", year: 2022, license_plate: "ABC123", daily_rate: 45.00, car_type: "small" },
  { make: "Honda", model: "Civic", year: 2023, license_plate: "DEF456", daily_rate: 48.00, car_type: "small" },
  { make: "Ford", model: "Focus", year: 2021, license_plate: "GHI789", daily_rate: 42.00, car_type: "small" },
  { make: "Toyota", model: "Camry", year: 2023, license_plate: "JKL012", daily_rate: 55.00, car_type: "city" },
  { make: "Honda", model: "Accord", year: 2022, license_plate: "MNO345", daily_rate: 58.00, car_type: "city" },
  { make: "Nissan", model: "Altima", year: 2023, license_plate: "PQR678", daily_rate: 52.00, car_type: "city" },
  { make: "Toyota", model: "RAV4", year: 2023, license_plate: "STU901", daily_rate: 65.00, car_type: "suv" },
  { make: "Honda", model: "CR-V", year: 2022, license_plate: "VWX234", daily_rate: 68.00, car_type: "suv" },
  { make: "Ford", model: "Escape", year: 2023, license_plate: "YZA567", daily_rate: 62.00, car_type: "suv" },
  { make: "Jeep", model: "Cherokee", year: 2022, license_plate: "BCD890", daily_rate: 75.00, car_type: "suv" }
]

cars_data.each do |car_attrs|
  Car.find_or_create_by!(license_plate: car_attrs[:license_plate]) do |car|
    car.assign_attributes(car_attrs)
  end
end

puts "Created #{Car.count} cars"

# Create admin user if it doesn't exist
admin_user = User.find_or_create_by!(email: "admin@carrental.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "admin"
  user.first_name = "Admin"
  user.last_name = "User"
end

puts "Admin user: #{admin_user.email} (password: password123)"

# Create sample regular users
regular_user1 = User.find_or_create_by!(email: "user@carrental.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "user"
  user.first_name = "John"
  user.last_name = "Doe"
end

regular_user2 = User.find_or_create_by!(email: "jane@carrental.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "user"
  user.first_name = "Jane"
  user.last_name = "Smith"
end

puts "Regular user 1: #{regular_user1.email} (password: password123)"
puts "Regular user 2: #{regular_user2.email} (password: password123)"

# Create sample reservations with different statuses
puts "Creating sample reservations..."

# Clear existing reservations to avoid conflicts
Reservation.destroy_all

# User 1 - Overdue reservation (ended 5 days ago, not returned)
overdue_reservation1 = Reservation.new(
  user: regular_user1,
  car: Car.find_by(license_plate: "ABC123"),
  start_date: 10.days.ago,
  end_date: 5.days.ago,
  total_price: 225.00,
  created_by: regular_user1
)
overdue_reservation1.save(validate: false)

# User 1 - In progress reservation (started 2 days ago, ends in 3 days)
in_progress_reservation1 = Reservation.new(
  user: regular_user1,
  car: Car.find_by(license_plate: "DEF456"),
  start_date: 2.days.ago,
  end_date: 3.days.from_now,
  total_price: 240.00,
  created_by: regular_user1
)
in_progress_reservation1.save(validate: false)

# User 2 - Overdue reservation (ended 3 days ago, not returned)
overdue_reservation2 = Reservation.new(
  user: regular_user2,
  car: Car.find_by(license_plate: "GHI789"),
  start_date: 8.days.ago,
  end_date: 3.days.ago,
  total_price: 210.00,
  created_by: regular_user2
)
overdue_reservation2.save(validate: false)

# User 2 - In progress reservation (started 1 day ago, ends in 4 days)
in_progress_reservation2 = Reservation.new(
  user: regular_user2,
  car: Car.find_by(license_plate: "JKL012"),
  start_date: 1.day.ago,
  end_date: 4.days.from_now,
  total_price: 275.00,
  created_by: regular_user2
)
in_progress_reservation2.save(validate: false)

# Admin - Overdue reservation (ended 7 days ago, not returned)
admin_overdue_reservation = Reservation.new(
  user: admin_user,
  car: Car.find_by(license_plate: "MNO345"),
  start_date: 12.days.ago,
  end_date: 7.days.ago,
  total_price: 290.00,
  created_by: admin_user
)
admin_overdue_reservation.save(validate: false)

# Admin - In progress reservation (started 3 days ago, ends in 2 days)
admin_in_progress_reservation = Reservation.new(
  user: admin_user,
  car: Car.find_by(license_plate: "PQR678"),
  start_date: 3.days.ago,
  end_date: 2.days.from_now,
  total_price: 260.00,
  created_by: admin_user
)
admin_in_progress_reservation.save(validate: false)

puts "Created #{Reservation.count} reservations"
puts "Seed data completed successfully!"
