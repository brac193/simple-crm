class Admin::InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_invoice, only: [ :show, :mark_paid ]

  def index
    @invoices = Invoice.includes(:user, reservation: :car).order(created_at: :desc)

    case params[:status]
    when "pending"
      @invoices = @invoices.pending
    when "paid"
      @invoices = @invoices.paid
    when "overdue"
      @invoices = @invoices.overdue
    end

    @invoices = @invoices.where(user_id: params[:user_id]) if params[:user_id].present?
  end

  def show
  end

  def mark_paid
    if @invoice.mark_as_paid!
      redirect_to admin_invoices_path, notice: "Invoice marked as paid successfully."
    else
      redirect_to admin_invoices_path, alert: "Failed to mark invoice as paid."
    end
  end

  private

  def set_invoice
    @invoice = Invoice.includes(reservation: :car).find(params[:id])
  end

  def ensure_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end
end
