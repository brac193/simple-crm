class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: "admin", user: "user" }

  has_many :reservations, dependent: :destroy
  has_many :cars, through: :reservations
  has_many :invoices, through: :reservations

  def full_name
    "#{first_name} #{last_name}".strip.presence || email
  end

  def active_reservations
    reservations.current
  end

  def upcoming_reservations
    reservations.upcoming
  end

  def past_reservations
    reservations.past
  end

  def overdue_reservations
    reservations.overdue_returns
  end

  def pending_invoices
    invoices.pending
  end

  def overdue_invoices
    invoices.overdue
  end

  def upcoming_reservations_count
    read_attribute(:upcoming_reservations_count)
  end

  def past_reservations_count
    read_attribute(:past_reservations_count)
  end

  def update_reservation_counts
    update_columns(
      upcoming_reservations_count: reservations.upcoming.count,
      past_reservations_count: reservations.past.count
    )
  end
end
