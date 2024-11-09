require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    let(:merchant) { Merchant.create!(name: "Test Merchant") }

    context 'when the merchant already has 5 active coupons' do
      before do
        5.times do |i|
          Coupon.create!(
            name: "Coupon #{i + 1}",
            code: "COUPON#{i + 1}",
            discount_type: "percent",
            discount_value: 10,
            status: true,
            merchant: merchant
          )
        end
      end

      it 'is not valid to create a 6th active coupon' do
        coupon = Coupon.new(
          name: "Coupon 6",
          code: "COUPON6",
          discount_type: "percent",
          discount_value: 10,
          status: true,
          merchant: merchant
        )
        expect(coupon).to be_invalid
        expect(coupon.errors[:base]).to include("Merchant cannot have more than 5 active coupons.")
      end
    end

    context 'when the merchant has less than 5 active coupons' do
      it 'is valid to create a new active coupon' do
        coupon = Coupon.new(
          name: "Coupon 1",
          code: "COUPON1",
          discount_type: "percent",
          discount_value: 10,
          status: true,
          merchant: merchant
        )
        expect(coupon).to be_valid
      end
    end
  end
end