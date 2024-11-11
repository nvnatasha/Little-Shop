class Api::V1::MerchantsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record_response

  def index
    merchants = Merchant.queried(params).order(:id)
  
    if params[:count] == 'true'
      render json: MerchantSerializer.format_with_counts(merchants)
    else
      render json: MerchantSerializer.new(merchants)
    end
  end

  def create
    merchant = Merchant.create!(merchant_params)
    render json:MerchantSerializer.new(merchant), status: 201
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update!(merchant_params)
    render json:MerchantSerializer.new(merchant)
  end

  def destroy
    merchant = Merchant.find(params[:id])
    merchant.destroy
    head :no_content 
  end

  def show
    merchant = Merchant.getMerchant(params)
    if merchant.is_a?(String)
      render json: {"message": "your query could not be completed", "errors": ["#{merchant}"]}, status: 404
    else
      render json: MerchantSerializer.new(merchant)
    end
  end

  def find
    merchant = Merchant.find_by_params(params)
 
    if merchant.is_a?(Hash) && merchant[:error]
      render json: { data: { message: "no merchant found", errors: [merchant.to_s], status: 200 } }, status: 200
    else
      render json: MerchantSerializer.new(merchant)
    end
  end

  private

  def merchant_params
    params.permit(:name)
  end

  def not_found_response(exception = "Record not found")
    render json: { message: "your request could not be completed", errors: [exception.to_s] }, status: :not_found
  end

  def invalid_record_response(exception)
    render json: { message: "your request could not be completed", errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def error_messages(messages, status)
    {
      message: "your request could not be completed",
      errors: messages,
      status: status
    }
  end
end