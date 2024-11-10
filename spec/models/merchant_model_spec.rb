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
    it 'is valid with a name' do
      merchant = build(:merchant, name: 'Test Merchant')
      expect(merchant).to be_valid
    end

    it 'is invalid without a name' do
      merchant = build(:merchant, name: nil)
      expect(merchant).not_to be_valid
      expect(merchant.errors[:name]).to include("can't be blank")
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

    it 'returns all merchants without sorting when an invalid sort parameter is given' do
      merchants = Merchant.sort({ sorted: "unknown" })
      expect(merchants).to match_array([@merchant1, @merchant2, @merchant3, @merchant4])
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

      it 'returns the merchant with a matching name if found' do
        merchant = create(:merchant, name: 'Cat Store')
        expect(Merchant.find_by_params({ name: 'Cat Store' })).to eq(merchant)
      end
    
      it 'returns an error message if no merchant with the specified name is found' do
        expect(Merchant.find_by_params({ name: 'Nonexistent Store' })).to eq(
          error: { message: 'No merchant found', status: 404 }
        )
      end
    
      it 'returns an error message if name parameter is missing' do
        expect(Merchant.find_by_params({})).to eq(
          error: { message: 'you need to specify a name', status: 404 }
        )
      end
 
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

    it 'returns merchants with item count included' do
      merchant = create(:merchant)
      create_list(:item, 3, merchant: merchant)
      merchant_with_count = Merchant.with_item_count.find(merchant.id)

      expect(merchant_with_count.item_count).to eq(3)
    end
  
    it 'returns merchants with an item count of 0 if they have no items' do
      merchant_without_items = create(:merchant)
      result = Merchant.with_item_count.find(merchant_without_items.id)
      expect(result.item_count).to eq(0)
    end
  
    it 'returns sorted merchants with item count when both count and sorted are true' do
      merchant = create(:merchant)
      create_list(:item, 3, merchant: merchant)  # Ensure 3 items for the merchant
      result = Merchant.queried({ count: 'true', sorted: 'age' })
      expect(result.first.item_count).to eq(3)  # Expects 3 items
    end
  

  it 'returns an error message if given a non-integer item_id' do
    result = Merchant.getMerchant({ item_id: "invalid" })
    expect(result).to eq("Couldn't find Item with 'id'=invalid")
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

  describe '.getMerchant' do
    it 'returns the merchant of a given item when params[:item_id] is present' do
      merchant = create(:merchant)
      item = create(:item, merchant: merchant)
      expect(Merchant.getMerchant({ item_id: item.id })).to eq(merchant)
    end
  
    it 'returns an error message if item with given item_id is not found' do
      expect(Merchant.getMerchant({ item_id: -1 })).to eq("Couldn't find Item with 'id'=-1")
    end
  
    it 'returns the merchant with a given id' do
      merchant = create(:merchant)
      expect(Merchant.getMerchant({ id: merchant.id })).to eq(merchant)
    end
  
    it 'returns an error message if merchant with given id is not found' do
      expect(Merchant.getMerchant({ id: -1 })).to eq("Couldn't find Merchant with 'id'=-1")
    end
  end

  
end
