FactoryBot.define do
    factory :item do
      name { 'cat toy' }
      description { 'mouse' }
      unit_price { 3.99 }  # Creates a customer record for the invoice
      association :merchant   # Creates a merchant record for the invoice
  # Creates a coupon record for the invoice, if needed
  
      # Add any other attributes needed for your invoice model
    end
  end