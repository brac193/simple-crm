class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def dashboard
    @total_users = User.count
    @total_cars = Car.count
    @total_reservations = Reservation.count
    @active_reservations = Reservation.current.count
    @upcoming_reservations = Reservation.upcoming.count

    @recent_reservations = Reservation.includes(:user, :car, :created_by)
                                    .order(created_at: :desc)
                                    .limit(10)
  end

  def users
    @users = User
                 .order(created_at: :desc)
  end

  def reservations
    @reservations = Reservation.includes(:user, :car, :created_by)
                              .order(start_date: :desc)

    @reservations = @reservations.current if params[:status] == "active"
    @reservations = @reservations.upcoming if params[:status] == "upcoming"
    @reservations = @reservations.past if params[:status] == "past"

    @reservations = @reservations.joins(:user).where(users: { id: params[:user_id] }) if params[:user_id].present?
    @reservations = @reservations.joins(:car).where(cars: { car_type: params[:car_type] }) if params[:car_type].present?
  end

  private

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
