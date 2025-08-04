class Reservation < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :car, counter_cache: true
  belongs_to :created_by, class_name: "User", optional: true
  has_one :invoice, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :total_price, presence: true, numericality: { greater_than: 0 }
  validate :end_date_after_start_date
  validate :start_date_not_in_past
  validate :car_available_for_dates
  validate :reservation_duration_reasonable
  validate :no_overlapping_reservations

  before_validation :calculate_total_price, on: :create
  after_save :update_user_reservation_counts
  after_destroy :update_user_reservation_counts
  after_update :generate_invoice_when_returned, if: :saved_change_to_returned_at?

  scope :upcoming, -> { where("start_date >= ?", Date.current) }
  scope :past, -> { where("end_date < ? OR returned_at IS NOT NULL", Date.current) }
  scope :current, -> { where("start_date <= ? AND end_date >= ? AND returned_at IS NULL", Date.current, Date.current) }
  scope :ended, -> { where("end_date < ?", Date.current) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :not_returned, -> { where(returned_at: nil) }
  scope :overdue_returns, -> { ended.not_returned }

  def duration_days
    (end_date - start_date).to_i
  end

  def is_active?
    start_date <= Date.current && end_date >= Date.current
  end

  def is_upcoming?
    start_date > Date.current
  end

  def is_past?
    end_date < Date.current
  end

  def is_returned?
    returned_at.present?
  end

  def is_completed?
    is_past? || is_returned?
  end

  def is_overdue?
    end_date < Date.current && returned_at.nil?
  end

  def days_overdue
    return 0 unless is_overdue?
    (Date.current - end_date).to_i
  end

  def mark_as_returned!
    update_success = update_column(:returned_at, Time.current)
    return false unless update_success

    recalculate_total_price_for_early_return!
    generate_invoice! unless invoice.present?

    true
  end

  def actual_rental_days
    if is_returned?
      (returned_at.to_date - start_date).to_i
    else
      duration_days
    end
  end

  def recalculate_total_price_for_early_return!
    return unless is_returned?

    actual_days = actual_rental_days
    new_total_price = car.daily_rate * actual_days

    update_column(:total_price, new_total_price)
  end

  def calculate_penalty_amount
    if is_returned?
      days_overdue_before_return = [ (returned_at.to_date - end_date).to_i, 0 ].max
      days_overdue_before_return * car.daily_rate * 2
    elsif is_overdue?
      days_overdue * car.daily_rate * 2
    else
      0
    end
  end

  def admin_discount?
    created_by&.admin?
  end

  def discount_percentage
    admin_discount? ? 20 : 0
  end

  def discount_amount
    return 0 unless admin_discount?
    total_price * 0.20
  end

  def final_amount_after_discount
    total_price - discount_amount
  end

  def generate_invoice!
    return if invoice.present?

    penalty_amount = calculate_penalty_amount
    base_amount = final_amount_after_discount

    create_invoice!(
      user: user,
      amount: base_amount,
      penalty_amount: penalty_amount
    )
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def start_date_not_in_past
    return if start_date.blank?

    if start_date < Date.current
      errors.add(:start_date, "cannot be in the past")
    end
  end

  def car_available_for_dates
    return if car.blank? || start_date.blank? || end_date.blank?

    unless car.available_for_dates?(start_date, end_date)
      errors.add(:base, "Car is not available for the selected dates")
    end
  end

  def reservation_duration_reasonable
    return if start_date.blank? || end_date.blank?

    duration = duration_days
    if duration > 30
      errors.add(:base, "Reservation cannot exceed 30 days")
    elsif duration < 1
      errors.add(:base, "Reservation must be at least 1 day")
    end
  end

  def no_overlapping_reservations
    return if car.blank? || start_date.blank? || end_date.blank?

    overlapping = car.reservations.where.not(id: id).where(
      "(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?) OR (start_date >= ? AND end_date <= ?)",
      end_date, start_date, start_date, start_date, start_date, end_date
    ).exists?

    if overlapping
      errors.add(:base, "This car is already reserved for the selected dates")
    end
  end

  def calculate_total_price
    return if car.blank? || start_date.blank? || end_date.blank?

    days = duration_days
    self.total_price = car.daily_rate * days
  end

  def update_user_reservation_counts
    user.update_reservation_counts if user.present?
  end

  def generate_invoice_when_returned
    return unless is_past?

    generate_invoice! if is_returned?
  end
end
