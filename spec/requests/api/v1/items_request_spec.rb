require 'rails_helper'

RSpec.describe "Items API", type: :request do 
  before(:each) do
    @merchant = Merchant.create(name: "Awesome Merchant") 
    @item1 = Item.create(
      name: "Catnip Toy",
      description: "A soft toy filled with catnip.",
      unit_price: 12.99,
      merchant_id: @merchant.id
    )

    @item2 = Item.create(
      name: "Laser Pointer",
      description: "A laser pointer to keep your cat active.",
      unit_price: 9.99,
      merchant_id: @merchant.id
    )

    @item3 = Item.create(
      name: "Feather Wand",
      description: "A wand with feathers to entice your kitty.",
      unit_price: 15.50,
      merchant_id: @merchant.id
    )
  end

  context "when the request is valid" do
    let(:valid_attributes) do
      {
        item: {
          name: "Cat Tower",
          description: "A tower for cats to climb and play.",
          unit_price: 45.00,
          merchant_id: @merchant.id
        }
      }
    end

    it "creates a new item" do
      expect {
        post "/api/v1/items", params: valid_attributes
      }.to change(Item, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['attributes']['name']).to eq("Cat Tower")
      expect(json_response['data']['attributes']['unit_price']).to eq(45.00)
    end
  end  # This end correctly closes the context block.

  it 'can fetch all items' do
    get '/api/v1/items'
    
    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    items = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(items).to be_an(Array)

    item = items[0]
    expect(item[:id].to_i).to be_an(Integer)
    expect(item[:type]).to eq('item')

    attrs = item[:attributes]

    expect(attrs[:name]).to be_an(String)
    expect(attrs[:description]).to be_an(String)
    expect(attrs[:unit_price]).to be_a(Float)
    expect(attrs[:merchant_id]).to be_an(Integer)
  end  

  it "can fetch all items when there are no items" do
    Item.destroy_all
  
    get "/api/v1/items"
    expect(response).to be_successful
    items = JSON.parse(response.body)
    expect(items["data"].count).to eq(0)
  end

  it 'can fetch an individual item' do
    get "/api/v1/items/#{@item1.id}"
    
    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    item = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(item[:id].to_i).to eq(@item1.id)
    expect(item[:type]).to eq('item')

    attrs = item[:attributes]
    
    expect(attrs[:name]).to eq(@item1.name)
    expect(attrs[:description]).to eq(@item1.description)
    expect(attrs[:unit_price]).to eq(@item1.unit_price)
    expect(attrs[:merchant_id]).to eq(@item1.merchant_id)
  end

  it 'can sort items by price' do
    get '/api/v1/items', params: { sorted: 'price' }

    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    items = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(items).to be_an(Array)
    
    expect(items[0][:id].to_i).to eq(@item2.id) 
    expect(items[1][:id].to_i).to eq(@item1.id) 
    expect(items[2][:id].to_i).to eq(@item3.id) 
  end

  it "can fetch multiple items" do
    get "/api/v1/items"
    expect(response).to be_successful
    items = JSON.parse(response.body)
    expect(items["data"].count).to eq(3)

    items["data"].each do |item|
      expect(item).to have_key("id")
      expect(item["id"]).to be_a(String)
      expect(item).to have_key("type")
      expect(item["type"]).to eq("item")
      expect(item["attributes"]).to have_key("name")
      expect(item["attributes"]["name"]).to be_a(String)
    end
  end

  describe 'delete single item' do
    it 'can delete a single item' do
      itemCount = Item.count
      delete "/api/v1/items/#{@item1.id}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(response.body).to be_empty
      expect(Item.count).to eq(itemCount - 1)
    end

    it 'returns an error if the requested item does not exist' do
      itemCount = Item.count
      item1Id = @item1.id
      @item1.destroy

      delete "/api/v1/items/#{item1Id}" 
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your query could not be completed")
      expect(error_response["errors"]).to include("Couldn't find Item with 'id'=#{item1Id}")
    end
  end

  describe "sad path test" do
    it "returns an error if the item does not exist" do
      get "/api/v1/items/3231" 
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      
      expect(error_response["errors"].first["title"]).to eq("Couldn't find Item with 'id'=3231")
    end
  end
end