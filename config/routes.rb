Rails.application.routes.draw do
  devise_for :users

  # Car rental service routes
  resources :cars do
    member do
      get :availability
    end
  end

  resources :reservations do
    member do
      get :cancel
      patch :cancel
    end
  end

  # User dashboard
  get "dashboard", to: "dashboard#index"
  get "my_reservations", to: "reservations#my_reservations"

  # Admin routes (only for admin users)
  get "admin", to: "admin#dashboard"
  get "admin/users", to: "admin#users"
  get "admin/reservations", to: "admin#reservations"

  namespace :admin do
    resources :returns, only: [ :index ] do
      member do
      patch :mark_returned
      end
    end
    resources :invoices, only: [ :index, :show ] do
      member do
        patch :mark_paid
      end
    end
  end

  # Root route
  root "cars#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
