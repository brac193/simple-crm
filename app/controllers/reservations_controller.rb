class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [ :show, :edit, :update, :destroy, :cancel ]

  def index
    @reservations = current_user.reservations.includes(:car, :created_by).order(start_date: :desc)

    case params[:filter]
    when "active"
      @reservations = @reservations.current
    when "upcoming"
      @reservations = @reservations.upcoming
    when "past"
      @reservations = @reservations.past
    end
  end

  def my_reservations
    @active_reservations = current_user.active_reservations.includes(:car, :created_by)
    @upcoming_reservations = current_user.upcoming_reservations.includes(:car, :created_by)
    @past_reservations = current_user.past_reservations.includes(:car, :created_by)
  end

  def show
  end

  def new
    @reservation = Reservation.new
    @reservation.car = Car.find(params[:car_id]) if params[:car_id].present?
  end

  def create
    @reservation = current_user.reservations.build(reservation_params)
    @reservation.created_by = current_user

    if @reservation.save
      redirect_to @reservation, notice: "Reservation was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @reservation.update(reservation_params)
      redirect_to @reservation, notice: "Reservation was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation.destroy
    if current_user.admin?
      redirect_to admin_reservations_path, notice: "Reservation was successfully cancelled."
    else
      redirect_to reservations_url, notice: "Reservation was successfully cancelled."
    end
  end

  def cancel
    if @reservation.is_upcoming?
      @reservation.destroy
      if current_user.admin?
        redirect_to admin_reservations_path, notice: "Reservation was successfully cancelled."
      else
        redirect_to my_reservations_path, notice: "Reservation was successfully cancelled."
      end
    else
      redirect_to @reservation, alert: "Cannot cancel past or active reservations."
    end
  end

  private

  def set_reservation
    if current_user.admin?
      @reservation = Reservation.find(params[:id])
    else
      @reservation = current_user.reservations.find(params[:id])
    end
  end

  def reservation_params
    params.require(:reservation).permit(:car_id, :start_date, :end_date)
  end
end
