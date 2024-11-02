require 'rails_helper'

RSpec.describe "merchants destroy action" do
  describe "happy path tests" do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')

      @item1 = Item.create(
      name: "Catnip Toy",
      description: "A soft toy filled with catnip.",
      unit_price: 12.99,
      merchant_id: @merchant2.id
      )
      @item2 = Item.create(
      name: "Laser Pointer",
      description: "A laser pointer to keep your cat active.",
      unit_price: 9.99,
      merchant_id: @merchant2.id
      )
    end

    it "can delete a merchant" do
      merchant_count = Merchant.count
      expect(merchant_count).to eq(4)

      delete "api/v1/merchants/#{@merchant2.id}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(response.body).to be_empty
      
      merchant_count = Merchant.count
      expect(merchant_count).to eq(3)
    end

    it "deletes all of the merchants items when a merchant is deleted" do
      item_count = Item.count
      expect(item_count).to eq(2)

      delete "api/v1/merchants/#{@merchant2.id}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(response.body).to be_empty

      item_count = Item.count
      expect(item_count).to eq(0)
    end
  end

  describe "sad path test" do
    it "returns an error if the merchant does not exist" do
      no_merchant = @merchant2.id + 5

      delete "/api/v1/merchants/#{no_merchant}", params: { name: 'No Name' } 
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Couldn't find Merchant with 'id'=#{no_merchant}")
    end
  end
end