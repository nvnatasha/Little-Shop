class MerchantSerializer
  include JSONAPI::Serializer 
  attributes :name

  def self.format_with_item_count(merchants)
    {
      data: merchants.map do |merchant|
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name,
            item_count: merchant.item_count
          }
        }
      end
    }
  end
end