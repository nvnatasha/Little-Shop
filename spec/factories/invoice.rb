FactoryBot.define do
    factory :invoice do
      status { 'completed' }
      association :customer   # Creates a customer record for the invoice
      association :merchant   # Creates a merchant record for the invoice
      association :coupon     # Creates a coupon record for the invoice, if needed
  
      # Add any other attributes needed for your invoice model
    end
  end
  