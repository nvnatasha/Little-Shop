require 'rails_helper'

RSpec.describe "merchants update action" do
  describe "happy path test" do  
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end
    
    it "can update a merchant" do
      current_name = @merchant4.name
      updated_name = { name: 'Sweep the leg, Johnny' }

      patch "/api/v1/merchants/#{@merchant4.id}", params: updated_name
      expect(response).to be_successful

      merchant_response = JSON.parse(response.body)

      expect(merchant_response).to have_key("data")
      expect(merchant_response["data"]["id"]).to eq(@merchant4.id.to_s)
      expect(merchant_response["data"]["type"]).to eq("merchant")
      expect(merchant_response["data"]["attributes"]["name"]).to eq('Sweep the leg, Johnny')
    
      updated_merchant = Merchant.find(@merchant4.id)
      expect(updated_merchant.name).to_not eq('Jonathan')
      expect(updated_merchant.name).to eq('Sweep the leg, Johnny')
    end
  end

  describe "sad path test" do
    it "returns an error if the merchant does not exist" do
      no_merchant = @merchant2.id + 5

      patch "/api/v1/merchants/#{no_merchant}", params: { name: 'No Name' } 
      expect(response).to_not be_successful
      expect(response.status).to eq(404)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Couldn't find Merchant with 'id'=#{no_merchant}")
    end

    it "returns an error if an attribute is missing" do
      current_name = @merchant3.name
      updated_name = { name: 'No Name' }

      patch "/api/v1/merchants/#{@merchant3.id}", params: {name: ""}
      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Name can't be blank")
    end
  end
end