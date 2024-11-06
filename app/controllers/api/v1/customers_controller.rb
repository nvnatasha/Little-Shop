class Api::V1::CustomersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

  def index
    merchant = Merchant.find(params[:merchant_id])
    customers = Customer.find_by_merchant(params[:merchant_id])
    render json: CustomerSerializer.format_customers(customers)
  end
        
  def show
    customer = Customer.find(params[:id])
    render json: CustomerSerializer.format_customer(customer)
  end

  private 
  def not_found_response
    render json: { message: "Resource not found" }, status: :not_found
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name)
  end

end