class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :reservation
  has_one :car, through: :reservation

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :penalty_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending paid overdue] }
  validates :due_date, presence: true

  enum :status, { pending: "pending", paid: "paid", overdue: "overdue" }

  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: "paid") }
  scope :overdue, -> { where(status: "overdue") }
  scope :due_today, -> { where(due_date: Date.current) }
  scope :overdue_invoices, -> { where("due_date < ? AND status = ?", Date.current, "pending") }

  before_validation :calculate_total_amount, on: :create
  before_validation :set_due_date, on: :create

  def calculate_penalty_amount
    return 0 if reservation.returned_at.present?

    if reservation.end_date < Date.current
      days_overdue = (Date.current - reservation.end_date).to_i
      daily_penalty_rate = reservation.car.daily_rate * 2
      days_overdue * daily_penalty_rate
    else
      0
    end
  end

  def mark_as_paid!
    update!(status: "paid", paid_at: Time.current)
  end

  def overdue?
    due_date < Date.current && status == "pending"
  end

  def days_overdue
    return 0 unless overdue?
    (Date.current - due_date).to_i
  end

  def formatted_amount
    "$%.2f" % amount
  end

  def formatted_penalty_amount
    "$%.2f" % penalty_amount
  end

  def formatted_total_amount
    "$%.2f" % total_amount
  end

  def has_admin_discount?
    reservation.admin_discount?
  end

  def original_amount
    reservation.total_price
  end

  def discount_amount
    reservation.discount_amount
  end

  def formatted_original_amount
    "$%.2f" % original_amount
  end

  def formatted_discount_amount
    "$%.2f" % discount_amount
  end

  private

  def calculate_total_amount
    self.total_amount = amount + penalty_amount
  end

  def set_due_date
    self.due_date = reservation.end_date + 7.days
  end
end
