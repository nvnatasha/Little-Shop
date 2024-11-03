require "rails_helper"

RSpec.describe "Merchants API" do
  describe "fetches merchants" do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end

    it "can fetch multiple merchants" do
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      expect(merchants["data"].count).to eq(4)

      merchants["data"].each do |merchant|
        expect(merchant).to have_key("id")
        expect(merchant["id"]).to be_a(String)
        expect(merchant).to have_key("type")
        expect(merchant["type"]).to eq("merchant")
        expect(merchant["attributes"]).to have_key("name")
        expect(merchant["attributes"]["name"]).to be_a(String)
      end
    end

    it "can fetch all merchants when there are no merchants" do
      Merchant.destroy_all
      
      get "/api/v1/merchants"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      expect(merchants["data"].count).to eq(0)
    end

    it "can sort merchants based on age" do
      get "/api/v1/merchants?sorted=age"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      
      expect(merchants["data"].count).to eq(4)
      expect(merchants["data"][0]["id"]).to be > (merchants["data"][1]["id"])
      expect(merchants["data"][1]["id"]).to be > (merchants["data"][2]["id"])
      expect(merchants["data"][2]["id"]).to be > (merchants["data"][3]["id"])
    end

    it "can sort merchants based on age when there is a gap in ids" do
      @merchant3.destroy
      get "/api/v1/merchants?sorted=age"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      
      expect(merchants["data"].count).to eq(3)
      expect(merchants["data"][0]["id"]).to be > (merchants["data"][1]["id"])
      expect(merchants["data"][1]["id"]).to be > (merchants["data"][2]["id"])
    end

    it "can sort merchants based on age when no merchants exist" do
      Merchant.destroy_all

      get "/api/v1/merchants?sorted=age"
      expect(response).to be_successful
      merchants = JSON.parse(response.body)
      expect(merchants["data"].count).to eq(0)
    end

    it 'can fetch a single merchant by id' do
      get "/api/v1/merchants/#{@merchant1.id}"
      expect(response).to be_successful
      merchant = JSON.parse(response.body)

      expect(merchant["data"]).to have_key("id")
      expect(merchant["data"]["id"]).to be_a(String)
      expect(merchant["data"]).to have_key("type")
      expect(merchant["data"]["type"]).to eq("merchant")
      expect(merchant["data"]["attributes"]).to have_key("name")
      expect(merchant["data"]["attributes"]["name"]).to eq("Wally")
    end

    it "returns an error when the merchant_id does not exist" do
      missing_id = @merchant2.id
      @merchant2.destroy

      get "/api/v1/merchants/#{missing_id}"
      # binding.pry
      expect(response).to_not be_successful
      expect(response.status).to eq(422)
  
      data = JSON.parse(response.body, symbolize_names: true)
  
      expect(data[:errors]).to be_a(Array)
      expect(data[:errors].first[:status]).to eq("422")
      expect(data[:errors].first[:message]).to eq("Couldn't find Merchant with 'id'=#{missing_id}") 
    end

    it "can fetch all items for a given merchant" do
      @item1 = Item.create(
        name: "Catnip Toy",
        description: "A soft toy filled with catnip.",
        unit_price: 12.99,
        merchant_id: @merchant1.id
      )

      @item2 = Item.create(
        name: "Laser Pointer",
        description: "A laser pointer to keep your cat active.",
        unit_price: 9.99,
        merchant_id: @merchant1.id
      )

      get "/api/v1/merchants/#{@merchant1.id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(items).to be_an(Array)

      item1 = items[0]
      expect(item1[:id].to_i).to be_an(Integer)
      expect(item1[:type]).to eq('item')

      attrs1 = item1[:attributes]

      expect(attrs1[:name]).to eq("Catnip Toy")
      expect(attrs1[:description]).to eq("A soft toy filled with catnip.")
      expect(attrs1[:unit_price]).to eq(12.99)
      expect(attrs1[:merchant_id]).to eq(@merchant1.id)

      item2 = items[1]
      expect(item2[:id].to_i).to be_an(Integer)
      expect(item2[:type]).to eq('item')

      attrs2 = item2[:attributes]

      expect(attrs2[:name]).to eq("Laser Pointer")
      expect(attrs2[:description]).to eq("A laser pointer to keep your cat active.")
      expect(attrs2[:unit_price]).to eq(9.99)
      expect(attrs2[:merchant_id]).to eq(@merchant1.id)
    end

    it "can fetch all items for a given merchant when none exist" do
      Item.destroy_all
      
      get "/api/v1/merchants/#{@merchant1.id}/items"
      expect(response).to be_successful
      items = JSON.parse(response.body)
      expect(items["data"].count).to eq(0)
    end

    it "returns an error when attempting to fetch all items for a given merchant that does not exist" do
      missingMerchant = @merchant1.id
      @merchant1.destroy
 
      get "/api/v1/merchants/#{missingMerchant}/items"

      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your query could not be completed")
      expect(error_response["errors"]).to include("Couldn't find Merchant with 'id'=#{missingMerchant}")
    end

    it "includes and item count when asked" do
      @item1 = Item.create(
      name: "Catnip Toy",
      description: "A soft toy filled with catnip.",
      unit_price: 12.99,
      merchant_id: @merchant1.id
      )
      @item2 = Item.create(
      name: "Laser Pointer",
      description: "A laser pointer to keep your cat active.",
      unit_price: 9.99,
      merchant_id: @merchant1.id
      )

      get "/api/v1/merchants?count=true"
      expect(response).to be_successful

      merchants = JSON.parse(response.body)

      expect(merchants["data"].count).to eq(4)
      merchants["data"].each do |merchant|
        expect(merchant).to have_key("id")
        expect(merchant["attributes"]).to have_key("name")
        expect(merchant["attributes"]).to have_key("item_count")

        individual_merchant = Merchant.find(merchant["id"].to_i)
        expect(merchant["attributes"]["item_count"]).to eq(individual_merchant.items.count)
      end
    end

    it "does not include item count when not asked for" do
      get "/api/v1/merchants"
      expect(response).to be_successful
    
      merchants = JSON.parse(response.body)
    
      expect(merchants["data"].count).to eq(4)
      merchants["data"].each do |merchant|
        expect(merchant["attributes"]).to have_key("name")
        expect(merchant["attributes"]).to_not have_key("item_count")
      end
    end
  end
end