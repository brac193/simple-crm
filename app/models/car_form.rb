class CarForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :make, :string
  attribute :model, :string
  attribute :year, :integer
  attribute :license_plate, :string
  attribute :daily_rate, :decimal
  attribute :car_type, :string

  validates :make, presence: true, length: { minimum: 2, maximum: 50 }
  validates :model, presence: true, length: { minimum: 1, maximum: 50 }
  validates :year, presence: true,
            numericality: {
              greater_than: 1900,
              less_than_or_equal_to: -> { Date.current.year + 1 },
              message: "must be between 1901 and #{Date.current.year + 1}"
            }
  validates :license_plate, presence: true,
            length: { minimum: 3, maximum: 20 },
            format: {
              with: /\A[A-Z0-9\s\-]+\z/i,
              message: "can only contain letters, numbers, spaces, and hyphens"
            }
  validates :daily_rate, presence: true,
            numericality: {
              greater_than: 0,
              less_than: 10000,
              message: "must be between $1 and $9,999 per day"
            }
  validates :car_type, presence: true,
            inclusion: {
              in: Car.car_types.keys,
              message: "must be one of: #{Car.car_types.keys.join(', ')}"
            }

  validate :license_plate_uniqueness
  validate :reasonable_daily_rate_for_car_type

  def initialize(attributes = {}, car = nil)
    super(attributes)
    @car = car || Car.new
  end

  def save
    return false unless valid?

    @car.assign_attributes(car_attributes)

    if @car.save
      true
    else
      @car.errors.each { |error| errors.add(error.attribute, error.message) }
      false
    end
  end

  def car
    @car
  end

  def car_types
    Car.car_types.map { |key, value| [ key.titleize, key ] }
  end

  def year_range
    current_year = Date.current.year
    (current_year - 10..current_year + 1).to_a.reverse
  end

  private

  def car_attributes
    {
      make: make,
      model: model,
      year: year,
      license_plate: license_plate&.upcase&.strip,
      daily_rate: daily_rate,
      car_type: car_type
    }
  end

  def license_plate_uniqueness
    return if license_plate.blank?

    existing_car = Car.find_by(license_plate: license_plate.upcase.strip)
    if existing_car && existing_car != @car
      errors.add(:license_plate, "is already registered to another car")
    end
  end

  def reasonable_daily_rate_for_car_type
    return if daily_rate.blank? || car_type.blank?

    case car_type
    when "small"
      if daily_rate > 100
        errors.add(:daily_rate, "seems too high for a small car (suggested: $20-$100)")
      elsif daily_rate < 20
        errors.add(:daily_rate, "seems too low for a small car (suggested: $20-$100)")
      end
    when "city"
      if daily_rate > 150
        errors.add(:daily_rate, "seems too high for a city car (suggested: $30-$150)")
      elsif daily_rate < 30
        errors.add(:daily_rate, "seems too low for a city car (suggested: $30-$150)")
      end
    when "suv"
      if daily_rate > 300
        errors.add(:daily_rate, "seems too high for an SUV (suggested: $50-$300)")
      elsif daily_rate < 50
        errors.add(:daily_rate, "seems too low for an SUV (suggested: $50-$300)")
      end
    end
  end
end
