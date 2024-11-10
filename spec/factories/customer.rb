FactoryBot.define do
    factory :customer do
    first_name { 'Amalee' }
    last_name { 'Keunemany' } # Creates a merchant record for the invoice
   # Creates a coupon record for the invoice, if needed
  
      # Add any other attributes needed for your invoice model
    end
  end