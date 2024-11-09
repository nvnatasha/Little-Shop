class CouponSerializer
    def self.format_coupons(coupons)
        {
            data: coupons.map do |coupon|
                {
                    id: coupon.id.to_s,
                    type: 'coupon',
                    attributes: {
                        name: coupon.name,
                        code: coupon.code,
                        discount_type: coupon.discount_type,
                        discount_value: coupon.discount_value,
                        status: coupon.status,
                        merchant_id: coupon.merchant_id,
                        usage_count: coupon.usage_count
                    }
                }
            end
        }
    end

    def self.format_coupon(coupon)
        {
            data: {
                id: coupon.id.to_s,
                type: "coupon",
                attributes: {
                    name: coupon.name,
                    code: coupon.code,
                    discount_type: coupon.discount_type,
                    discount_value: coupon.discount_value,
                    status: coupon.status,
                    merchant_id: coupon.merchant_id,
                    usage_count: coupon.usage_count
                }
            }
        }
    end
end