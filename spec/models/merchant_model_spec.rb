require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items)}
    it { should have_many(:invoices)}
    it { should have_many(:coupons) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "sort" do
    before :each do
      Merchant.destroy_all
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end

    it "can sort merchants based on age" do
      merchants = Merchant.sort({sorted: "age"})

      expect(merchants[0].created_at).to be > (merchants[1].created_at)
      expect(merchants[1].created_at).to be > (merchants[2].created_at)
      expect(merchants[2].created_at).to be > (merchants[3].created_at)
    end

    it "ignores sort if not passed as a parameter" do
      merchants = Merchant.sort({nonsense: "Fun nonsense"})
      expect(merchants[0].created_at).to be < (merchants[1].created_at)
      expect(merchants[1].created_at).to be < (merchants[2].created_at)
      expect(merchants[2].created_at).to be < (merchants[3].created_at)
    end
  end

  describe "dependent destroy" do
    it "destroys associated items when the merchant is deleted" do
      merchant = Merchant.create!(name: 'Frankenstein')
      Item.destroy_all
      item1 = merchant.items.create!(name: 'Head bolts', description: 'used as ears and to hold head on', unit_price: 10.99)
      item2 = merchant.items.create!(name: 'Thread', description: 'Used to sew limbs to body', unit_price: 20.99)
      expect(Item.count).to eq(2)
      merchant.destroy
      expect(Item.count).to eq(0)
    end
  end

  describe "self.getMerchant" do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @item1 = Item.create(
        name: "Catnip Toy",
        description: "A soft toy filled with catnip.",
        unit_price: 12.99,
        merchant_id: @merchant1.id
      )
    end

    it 'gets merchant if merchant_id is passed as param' do
      expect(Merchant.getMerchant({id: "#{@merchant1.id}"})).to eq(@merchant1)
    end

    it "gets merchant if item_id is passed as param" do
      expect(Merchant.getMerchant({item_id: "#{@item1.id}"})).to eq(@merchant1)
    end

    it "returns an error if item_id is passed as param but does not exist" do
      itemId = @item1.id
      @item1.destroy
      response = Merchant.getMerchant({item_id: "#{itemId}"})
      
      expect(response).to eq("Couldn't find Item with 'id'=#{itemId}")
    end
  end

  describe 'find' do
    before :each do
      Merchant.destroy_all
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end

    it 'finds the first matching merchant by name (case insensitive)' do
      merchant = Merchant.find_by_params({ name: 'na'})
      expect(merchant.id).to eq(@merchant3.id)
    end

    # it 'does not error when there are no matching merchants' do
    #   merchant = Merchant.find_by_params({ name: 'abdul'})
    #   expect(merchant).to eq([])
    # end

    it 'errors when a parameter is missing' do
      merchant = Merchant.find_by_params({})
      expect(merchant).to be_a(Hash)
    end

    it 'errors when a parameter is empty' do
      merchant = Merchant.find_by_params({ name: ''})
      expect(merchant).to be_a(Hash)
    end
  end

  describe '.queried' do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'Natasha')
      @item1 = Item.create(
        name: "Catnip Toy",
        description: "A soft toy filled with catnip.",
        unit_price: 12.99,
        merchant_id: @merchant1.id
      )
    end

    it 'returns merchants with item count when count parameter is true' do
      merchants = Merchant.queried({ count: 'true' })

      expect(merchants.first.item_count).to eq(1) 
      expect(merchants.find_by(id: @merchant2.id).item_count).to eq(0)
    end
  end

  describe 'coupon validation' do
    it 'should allow creating a valid coupon' do
      merchant = create(:merchant, name: 'Cat store')
      valid_coupon = create(:coupon, merchant: merchant)

      expect(valid_coupon).to be_valid
    end
    it 'should not allow creating a coupon without a name' do
      merchant = create(:merchant, name: 'Cat store')
      invalid_coupon = build(:coupon, name: nil, merchant: merchant)
      
      expect(invalid_coupon).not_to be_valid
      expect(invalid_coupon.errors[:name]).to include("can't be blank")
    end

    it 'should not allow creating a coupon without a code' do
      merchant = create(:merchant, name: 'Cat store')
      invalid_coupon = build(:coupon, code: nil, merchant: merchant)
      
      expect(invalid_coupon).not_to be_valid
      expect(invalid_coupon.errors[:code]).to include("can't be blank")
    end

    it 'should not allow creating a coupon without a discount_value' do
      merchant = create(:merchant, name: 'Cat store')
      invalid_coupon = build(:coupon, discount_value: nil, merchant: merchant)
      
      expect(invalid_coupon).not_to be_valid
      expect(invalid_coupon.errors[:discount_value]).to include("can't be blank")
    end

    it 'should not allow creating a coupon with a negative discount_value' do
      merchant = create(:merchant, name: 'Cat store')
      invalid_coupon = build(:coupon, discount_value: -10, merchant: merchant)
      
      expect(invalid_coupon).not_to be_valid
      expect(invalid_coupon.errors[:discount_value]).to include("must be greater than 0")
    end

    it 'should not allow creating a coupon with an invalid discount_type' do
      merchant = create(:merchant, name: 'Cat store')
      invalid_coupon = build(:coupon, discount_type: 'invalid_type', merchant: merchant)
      
      expect(invalid_coupon).not_to be_valid
      expect(invalid_coupon.errors[:discount_type]).to include("is not included in the list")
    end

    it 'should not allow creating a coupon with a duplicate code' do
      merchant = create(:merchant, name: 'Cat store')
      create(:coupon, code: '10OFF', merchant: merchant)
      duplicate_coupon = build(:coupon, code: '10OFF', merchant: merchant)
      
      expect(duplicate_coupon).not_to be_valid
      expect(duplicate_coupon.errors[:code]).to include("has already been taken")
    end

    it 'should not allow creating a coupon without a merchant' do
      invalid_coupon = build(:coupon, merchant: nil)
      
      expect(invalid_coupon).not_to be_valid
      expect(invalid_coupon.errors[:merchant]).to include("must exist")
    end
  end
end
