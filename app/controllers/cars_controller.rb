class CarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car, only: [ :show, :edit, :update, :destroy, :availability ]
  before_action :ensure_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    if request.path == root_path && !current_user.admin?
      redirect_to my_reservations_path
      return
    end

    @cars = Car.all
    @cars = @cars.where(car_type: params[:car_type]) if params[:car_type].present?
    @cars = @cars.where("daily_rate <= ?", params[:max_price]) if params[:max_price].present?
    @cars = @cars.where("year >= ?", params[:min_year]) if params[:min_year].present?
  end

  def show
    @reservation = Reservation.new(car: @car)

    respond_to do |format|
      format.html
      format.json { render json: {
        id: @car.id,
        display_name: @car.display_name,
        daily_rate: @car.daily_rate,
        car_type: @car.car_type
      } }
    end
  end

  def new
    @car_form = CarForm.new
  end

  def create
    @car_form = CarForm.new(car_params)

    if @car_form.save
      redirect_to @car_form.car, notice: "Car was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @car_form = CarForm.new(
      {
        make: @car.make,
        model: @car.model,
        year: @car.year,
        license_plate: @car.license_plate,
        daily_rate: @car.daily_rate,
        car_type: @car.car_type
      },
      @car
    )
  end

  def update
    @car_form = CarForm.new(car_params, @car)

    if @car_form.save
      redirect_to @car, notice: "Car was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @car.reservations.any?
      redirect_to @car, alert: "Cannot delete car with existing reservations."
    else
      @car.destroy
      redirect_to cars_url, notice: "Car was successfully deleted."
    end
  end

  def availability
    start_date = Date.parse(params[:start_date]) if params[:start_date].present?
    end_date = Date.parse(params[:end_date]) if params[:end_date].present?

    if start_date && end_date
      available = @car.available_for_dates?(start_date, end_date)
      render json: { available: available }
    else
      render json: { error: "Start date and end date are required" }, status: :bad_request
    end
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def car_params
    params.require(:car_form).permit(:make, :model, :year, :license_plate, :daily_rate, :car_type)
  end

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
