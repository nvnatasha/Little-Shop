require 'rails_helper'

RSpec.describe "Items API", type: :request do 
  before(:each) do
    Item.destroy_all
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
    
    expect(item[:id].to_i).to eq(@item1.id) # Convert `item[:id]` to integer
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
    it 'can delete an single item' do
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

    it 'deletes all associated invoice items when it deletes a single item' do
      customer = Customer.create!(first_name: "Wally", last_name: "Wallace")
      invoice = Invoice.create!(customer_id: customer.id, merchant_id: @merchant.id, status: "shipped")
      invoice2 = Invoice.create!(customer_id: customer.id, merchant_id: @merchant.id, status: "returned")
      invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: invoice.id, quantity: 3, unit_price: 9.99)
      invoice_item2 = InvoiceItem.create!(item_id: @item1.id, invoice_id: invoice2.id, quantity: 2, unit_price: 10.99)

      invoiceItemCount = InvoiceItem.count
      delete "/api/v1/items/#{@item1.id}"
      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(response.body).to be_empty
      expect(InvoiceItem.count).to eq(invoiceItemCount - 2)
    end
  end

  describe 'it can create an item' do
    it 'can create a valid item' do
      item_params = { name: 'New Item', description: 'I am a fun item', unit_price: 12.99, merchant_id: @merchant.id}
      post '/api/v1/items', params: item_params

      expect(response).to be_successful

      item_response = JSON.parse(response.body)

      expect(item_response).to have_key("data")
      expect(item_response["data"]["id"]).to be_present
      expect(item_response["data"]["type"]).to eq("item")
      expect(item_response["data"]["attributes"]["name"]).to eq("New Item")
      expect(item_response["data"]["attributes"]["description"]).to eq("I am a fun item")
      expect(item_response["data"]["attributes"]["unit_price"]).to eq(12.99)
      expect(item_response["data"]["attributes"]["merchant_id"]).to eq(@merchant.id)
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

  it 'can return the merchant associated with an item' do
    get "/api/v1/items/#{@item1.id}/merchant"
    expect(response).to be_successful
    merchant = JSON.parse(response.body)

    expect(merchant["data"]).to have_key("id")
    expect(merchant["data"]["id"]).to be_a(String)
    expect(merchant["data"]).to have_key("type")
    expect(merchant["data"]["type"]).to eq("merchant")
    expect(merchant["data"]["attributes"]).to have_key("name")
    expect(merchant["data"]["attributes"]["name"]).to eq("Awesome Merchant")
  end

  it 'returns a 404 if an item id does not exist when requesting the merchant' do
    missing_id = @item1.id
    @item1.destroy

    get "/api/v1/items/#{missing_id}/merchant"

    expect(response).to_not be_successful
    expect(response.status).to eq(404)

    data = JSON.parse(response.body, symbolize_names: true)

    expect(data[:errors]).to be_a(Array)
    expect(data[:message]).to eq("your query could not be completed") 
    expect(data[:errors].first).to eq("Couldn't find Item with 'id'=#{missing_id}") 
  end

  describe "updating an item" do

    xit 'creates a new item' do
      item_attributes = {
          name: "More Cat Things", 
          description: "Stuff to keep cats happy", 
          unit_price: 30.00, 
          merchant_id: @merchant.id
          }
      post '/api/v1/items', params: { item: item_attributes }

      item = JSON.parse(response.body, symbolize_names: true)[:data].first   
      expect(item[:attributes][:name]).to eq(item_attributes[:name])
      expect(item[:attributes][:description]).to eq(item_attributes[:description])
      expect(item[:attributes][:unit_price]).to eq(item_attributes[:unit_price])
    end


    it "returns an error if required params are missing(sadpath create)" do
      item_params = { description: "Cat litter made out of tofu", unit_price: nil, merchant_id: @merchant.id  }

      post "/api/v1/items", params:{item: item_params}
      
      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Name can't be blank")
    end
  

    it "can update an existing item" do
      id = Item.create(
        name: "More Cat Things", 
        description: "Stuff to keep cats happy", 
        unit_price: 30.00, 
        merchant_id: @merchant.id).id
      previous_name = Item.last.name
      item_params = { name: "Padam litter", description: "Cat litter made out of tofu", unit_price: 28.99 }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      item = Item.find_by(id: id)

      expect(response).to be_successful
      expect(item.name).to_not eq(previous_name)
      expect(item.name).to eq("Padam litter")
      expect(item.description).to eq("Cat litter made out of tofu")
      expect(item.unit_price).to eq(28.99)
    end
  end

  describe "sad path test" do
    it "returns an error if the item does not exist" do
      no_item = @item2.id + 5

      patch "/api/v1/items/#{no_item}", params: { name: 'No Name' } 
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Couldn't find Item with 'id'=#{no_item}")
    end

    it "returns an error if an attribute is missing" do
      current_name = @item3.name
      updated_name = { name: 'No Name' }
      item_params = { name: "", description: "Cat litter made out of tofu", unit_price: 28.99, merchant_id: @merchant.id  }

      patch "/api/v1/items/#{@item3.id}", params: {item: item_params}
      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Name can't be blank")
    end
  end
end


