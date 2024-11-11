class Api::V1::CouponsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    def index
      merchant = Merchant.find(params[:merchant_id])
      if params[:status].present?
 
        if params[:status] == 'true' || params[:status] == 'false'
          status = ActiveModel::Type::Boolean.new.cast(params[:status]) # Casts to true/false
          coupons = merchant.coupons.where(status: status)
        else
          render json: { error: 'Invalid status filter' }, status: :unprocessable_entity
          return
        end
      else
        coupons = merchant.coupons
      end
    
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
      coupon = merchant.coupons.build(coupon_params)
    
      if coupon.save
        render json: CouponSerializer.format_coupon(coupon), status: :created
      else
        render json: { error: coupon.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end
    end
    

    def update

      merchant = Merchant.find_by(id: params[:merchant_id])
      
      if merchant.nil?
        render json: { error: 'Merchant not found' }, status: :not_found
        return
      end

      coupon = merchant.coupons.find_by(id: params[:id])
    
      if coupon.nil?
        render json: { error: 'Coupon not found' }, status: :not_found
        return
      end
    
      if coupon.invoices.where(status: 'pending').exists?
        render json: { error: 'Cannot deactivate coupon with pending invoices' }, status: :unprocessable_entity
        return
      end
    
      if coupon.update(status: false)
        render json: CouponSerializer.format_coupon(coupon), status: :ok
      else
        render json: { error: 'Coupon could not be deactivated' }, status: :unprocessable_entity
      end
    end

    def activate
      merchant = Merchant.find_by(id: params[:merchant_id])
      unless merchant
        render json: { error: 'Merchant not found' }, status: :not_found
        return
      end
  
      coupon = merchant.coupons.find_by(id: params[:id])
      unless coupon
        render json: { error: 'Coupon not found' }, status: :not_found
        return
      end
  
      if coupon.update(status: true)
        render json: CouponSerializer.format_coupon(coupon), status: :ok
      else
        render json: { error: 'Coupon could not be activated' }, status: :unprocessable_entity
      end
    end

    private

    def coupon_params
      params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :status)
    end

    def record_not_found(error)
      render json: { error: error.message }, status: :not_found
    end
  
end