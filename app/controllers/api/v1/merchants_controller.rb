class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.sort(params)
    render json: MerchantSerializer.new(merchants)
  end

  def create
    begin
      merchant = Merchant.create!(merchant_params)
      render json:MerchantSerializer.new(merchant)
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: 422
    end
  end

  def update
    begin
      merchant = Merchant.find(params[:id])
      merchant.update!(merchant_params)
      render json:MerchantSerializer.new(merchant)
    rescue ActiveRecord::RecordNotFound => error
      render json: error_messages([error.message], 404), status: 404
    rescue ActiveRecord::RecordInvalid => errors
      render json: error_messages(errors.record.errors.full_messages, 422), status: 422
    end
  end

  def show
    begin
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    rescue ActiveRecord::RecordNotFound => error
      render json: {
        errors: [
          {
            status: "422",
            message: error.message
          }
        ]
      }, status: 422
    end
  end

  private

  def merchant_params
    params.permit(:name)
  end

  def error_messages(messages, status)
    {
      message: "your request could not be completed",
      errors: messages,
      status: status
    }
  end
end