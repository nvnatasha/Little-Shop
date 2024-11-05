class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.queried(params)
    if params[:count] == 'true'
      render json: MerchantSerializer.format_with_item_count(merchants)
    else
      render json: MerchantSerializer.new(merchants)
    end
  end

  def create
    begin
      merchant = Merchant.create!(merchant_params)
      render json:MerchantSerializer.new(merchant), status: 201
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

  def destroy
    begin
      merchant = Merchant.find(params[:id])
      merchant.destroy
      head :no_content 
    rescue ActiveRecord::RecordNotFound => error
      render json: error_messages([error.message], 404), status: 404
    end
  end

  def show
    merchant = Merchant.getMerchant(params)
    if merchant.is_a?(String)
      render json: {"message": "your query could not be completed", "errors": ["#{merchant}"]}, status: 404
    else
      render json: MerchantSerializer.new(merchant)
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