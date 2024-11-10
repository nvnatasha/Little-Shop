require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations and Sad Paths' do

    it 'creates a valid coupon' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create!(
        name: '$20 off',
        code: '20OFF',
        discount_value: 20,
        discount_type: 'dollar',
        merchant: merchant
      )

      expect(coupon).to be_valid
    end
  
    context 'merchant can only have up to 5 coupons' do
      merchant = Merchant.create!(name: "cat store")
    it 'has a merchant with 5 coupons' do
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
        merchant = Merchant.create!(name: "cat store")
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
        coupon = Coupon.create(
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
  
    context "requires a name" do
    it 'is invalid without a name' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create(
        code: '20OFF',
        discount_value: 20,
        discount_type: 'dollar',
        merchant: merchant
      )
      expect(coupon).to be_invalid
      expect(coupon.errors[:name]).to include("can't be blank")
    end
  end
  context "requires a code" do
    it 'is invalid without a code' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create(
        name: '$20 Off',
        discount_value: 20,
        discount_type: 'dollar',
        merchant: merchant
      )
      expect(coupon).to be_invalid
      expect(coupon.errors[:code]).to include("can't be blank")
    end
  end
  context "requires a discount value" do
    it 'is invalid without a discount value' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create(
        name: '$20 Off',
        code: '20OFF',
        discount_type: 'dollar',
        merchant: merchant
      )
      expect(coupon).to be_invalid
      expect(coupon.errors[:discount_value]).to include("can't be blank")
    end
  end
  context "requires a discount type" do
    it 'is invalid without a discount type' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create(
        name: '$20 Off',
        code: '20OFF',
        discount_value: 20,
        merchant: merchant
      )
      expect(coupon).to be_invalid
      expect(coupon.errors[:discount_type]).to include("can't be blank")
    end
  end

    context "discount needs to be greater than zero" do
    it 'is invalid with a discount value less than or equal to 0' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create(
        name: '$20 Off',
        code: '20OFF',
        discount_value: -20,
        discount_type: 'dollar',
        merchant: merchant
      )
      expect(coupon).to be_invalid
      expect(coupon.errors[:discount_value]).to include("must be greater than 0")
    end
  end
  context "requires a valid discount type" do
    it 'is invalid with an invalid discount type' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create(
        name: '$20 Off',
        code: '20OFF',
        discount_value: 20,
        discount_type: 'invalid_type',
        merchant: merchant
      )
      expect(coupon).to be_invalid
      expect(coupon.errors[:discount_type]).to include("is not included in the list")
    end
  end
    context "requires a unique code" do
    it 'is invalid with a non-unique code' do
      merchant = Merchant.create!(name: "cat store")
      coupon1 = Coupon.create(
      name: '$20 Off',
      code: '20OFF',
      discount_value: 20,
      discount_type: 'dollar',
      merchant: merchant)

      coupon2 = Coupon.create(
        name: 'Big Sale',
        code: '20OFF',
        discount_value: 20,
        discount_type: 'dollar',
        merchant: merchant
      )
      expect(coupon2).to be_invalid
      expect(coupon2.errors[:code]).to include("has already been taken")
    end
  end

    context 'when the merchant has less than 5 active coupons' do
      it 'is valid to create a new active coupon' do
        merchant = Merchant.create!(name: "cat store")
        coupon = Coupon.create!(
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

  context "returns only coupons that are active" do
    it 'returns only active coupons' do
      merchant = Merchant.create!(name: "cat store")

      active_coupon = Coupon.create(
          name: "Coupon 1",
          code: "COUPON1",
          discount_type: "percent",
          discount_value: 10,
          status: true,
          merchant: merchant
        )
      inactive_coupon = Coupon.create!(
        name: "Coupon 2",
        code: "COUPON2",
        discount_type: "percent",
        discount_value: 10,
        status: false,
        merchant: merchant
      )
      
      expect(Coupon.active).to include(active_coupon)
      expect(Coupon.active).to_not include(inactive_coupon)
    end

    it 'returns only inactive coupons' do
      merchant = Merchant.create!(name: "cat store")
      active_coupon = Coupon.create(
        name: "Coupon 1",
        code: "COUPON1",
        discount_type: "percent",
        discount_value: 10,
        status: true,
        merchant: merchant
      )
    inactive_coupon = Coupon.create!(
      name: "Coupon 2",
      code: "COUPON2",
      discount_type: "percent",
      discount_value: 10,
      status: false,
      merchant: merchant
    )
      
      expect(Coupon.inactive).to include(inactive_coupon)
      expect(Coupon.inactive).to_not include(active_coupon)
    end
  end
end 
end
  



