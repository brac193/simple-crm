class Admin::ReturnsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_reservation, only: [ :mark_returned ]

  def index
    @overdue_reservations = Reservation.overdue_returns.includes(:user, :car).order(end_date: :asc)
    @recently_ended = Reservation.ended.not_returned.includes(:user, :car).order(end_date: :desc).limit(10)
  end

  def mark_returned
    if @reservation.mark_as_returned!

      @reservation.generate_invoice! unless @reservation.invoice.present?

      if @reservation.is_active?
        message = "Car marked as returned early. Invoice recalculated based on actual rental days."
      elsif @reservation.is_overdue?
        message = "Car marked as returned successfully. Invoice generated with penalty fees."
      else
        message = "Car marked as returned successfully. Invoice generated."
      end

      redirect_to admin_returns_path, notice: message
    else
      redirect_to admin_returns_path, alert: "Failed to mark car as returned."
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
