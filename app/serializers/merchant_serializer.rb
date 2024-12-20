class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name, :coupons_count, :invoice_coupon_count


  def self.format_with_item_counts(merchants)
    {
      data: merchants.map do |merchant|
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name,
            item_count: merchant.items.count
          }
        }
      end
    }
  end

  def self.format_with_counts(merchant)
    {
      data:
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name,
            coupons_count: merchant.coupons.count,
            invoice_coupon_count: merchant.invoices.where.not(coupon_id: nil).count,
            item_count: merchant.items.count 
          }
        }
    }
  end
end
