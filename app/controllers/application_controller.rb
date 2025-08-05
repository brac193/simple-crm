class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  private

  def after_sign_in_path_for(resource)
    if resource.admin?
      cars_path
    else
      my_reservations_path
    end
  end
end
