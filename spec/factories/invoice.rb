FactoryBot.define do
    factory :invoice do
    status { 'completed' }
    association :customer   
    association :merchant   
    association :coupon     

    end
end