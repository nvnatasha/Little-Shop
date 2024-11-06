class Api::V1::InvoicesController < ApplicationController
  def index
    invoices = Invoice.filter(params)
    render json: InvoiceSerializer.format_invoices(invoices)
  end
      
  private
  def invoice_params
    params.require(:invoice).permit(:status, :merchant_id, :customer_id)
  end 
end