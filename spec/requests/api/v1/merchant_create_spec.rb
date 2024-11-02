require 'rails_helper'

RSpec.describe "merchants create action" do
  describe "happy path test" do
    it "can create a new merchant" do
      merchant_params = { name: 'I am a new Merchant'}

      post "/api/v1/merchants", params: merchant_params
      expect(response).to be_successful

      merchant_response = JSON.parse(response.body)

      expect(merchant_response).to have_key("data")
      expect(merchant_response["data"]["id"]).to be_present
      expect(merchant_response["data"]["type"]).to eq("merchant")
      expect(merchant_response["data"]["attributes"]["name"]).to eq("I am a new Merchant")
    end
  end

  describe "sad path test" do
    it "returns an error if required params are missing" do
      merchant_params = { name: " "}

      post "/api/v1/merchants", params: merchant_params
      expect(response).to_not be_successful
      expect(response.status).to eq(422)

      error_response = JSON.parse(response.body)
      expect(error_response["message"]).to eq("your request could not be completed")
      expect(error_response["errors"]).to include("Name can't be blank")
    end
  end
end