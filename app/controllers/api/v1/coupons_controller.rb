class Api::V1::CouponsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def index
      merchant = Merchant.find(params[:merchant_id])
      coupons = merchant.coupons
      render json: CouponSerializer.format_coupons(coupons), status: :ok
    end

    def show
      begin
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        render json: CouponSerializer.format_coupon(coupon), status: :ok
      rescue ActiveRecord::RecordNotFound => e
        if e.message.include?("Merchant")
          render json: { error: "Merchant not found" }, status: :not_found
        else
          render json: { error: "Coupon not found" }, status: :not_found
        end
      end
    end

    def create
      merchant = Merchant.find(params[:merchant_id])
      coupon = merchant.coupons.new(coupon_params)

      if coupon.save
        render json: CouponSerializer.format_coupon(coupon), status: :created
      else
        render json: { error: 'Coupon could not be created', details: coupon.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      merchant = Merchant.find(params[:merchant_id])
      coupon = merchant.coupons.find(params[:id])

      if coupon.update(coupon_params)
        render json: CouponSerializer.new(coupon).serializable_hash.to_json, status: :ok
      else
        render json: { error: 'Coupon could not be updated', details: coupon.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      merchant = Merchant.find(params[:merchant_id])
      coupon = merchant.coupons.find(params[:id])
      coupon.destroy
      head :no_content
    end

    def toggle_status
      merchant = Merchant.find(params[:merchant_id])
      coupon = merchant.coupons.find(params[:id])
      coupon.toggle!(:status)
      render json: CouponSerializer.new(coupon).serializable_hash.to_json, status: :ok
    end

    private

    def coupon_params
      params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :status)
    end

    def record_not_found(error)
      render json: { error: error.message }, status: :not_found
    end
  
end