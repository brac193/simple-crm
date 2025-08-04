class Car < ApplicationRecord
  enum :car_type, { small: "small", city: "city", suv: "suv" }

  has_many :reservations, dependent: :destroy
  has_many :users, through: :reservations

  validates :make, presence: true
  validates :model, presence: true
  validates :year, presence: true, numericality: { greater_than: 1900, less_than_or_equal_to: Date.current.year + 1 }
  validates :license_plate, presence: true, uniqueness: true
  validates :daily_rate, presence: true, numericality: { greater_than: 0 }
  validates :car_type, presence: true

  def available_for_dates?(start_date, end_date)
    return false if start_date >= end_date

    overlapping_reservations = reservations.where(
      "(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)",
      end_date, start_date, start_date, start_date, start_date, end_date
    )

    overlapping_reservations.none?
  end

  def display_name
    "#{year} #{make} #{model} (#{car_type.titleize})"
  end

  def current_reservations
    reservations.current
  end

  def upcoming_reservations
    reservations.upcoming
  end

  def past_reservations
    reservations.past
  end

  def current_reservations_count
    current_reservations.count
  end

  def upcoming_reservations_count
    upcoming_reservations.count
  end

  def past_reservations_count
    past_reservations.count
  end
end
