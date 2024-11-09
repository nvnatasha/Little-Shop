require 'rails_helper'

RSpec.describe "Merchant Coupons API", type: :request do
    describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
        it "returns a specific coupon for a merchant" do
          # Create a merchant
        merchant = Merchant.create!(name: "cat store")
    
          # Create a coupon associated with the merchant
        coupon = Coupon.create!(
            name: "Buy One Get One 50",
            code: "BOGO50",
            discount_type: "percent",
            discount_value: 50,
            status: true,
            merchant_id: merchant.id
        )
    
          # Send GET request to fetch the coupon
        get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
    
          # Check the response status
        expect(response).to have_http_status(:ok)
    
          # Parse the JSON response
        json_response = JSON.parse(response.body, symbolize_names: true)
    
          # Test the attributes
        expect(json_response[:data][:id]).to eq(coupon.id.to_s)
        expect(json_response[:data][:type]).to eq("coupon")
        expect(json_response[:data][:attributes][:name]).to eq("Buy One Get One 50")
        expect(json_response[:data][:attributes][:code]).to eq("BOGO50")
        expect(json_response[:data][:attributes][:discount_type]).to eq("percent")
        expect(json_response[:data][:attributes][:discount_value]).to eq(50)
        expect(json_response[:data][:attributes][:status]).to eq(true)
        end
    end


    it 'returns an empty list if no coupons exist for a merchant' do
      merchant_without_coupons = Merchant.create(name: 'Merchant2')
    
      get "/api/v1/merchants/#{merchant_without_coupons.id}/coupons"
    
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:ok)
      expect(json_response[:data]).to be_empty
    end

        it "returns a 404 Status if coupon ID is invalid" do
            merchant = Merchant.create!(name: "cat store")
            coupon = Coupon.create!(
                name: "Buy One Get One 50",
                code: "BOGO50",
                discount_type: "percent",
                discount_value: 50,
                status: true,
                merchant_id: merchant.id
            )
            invalid_merchant_id = merchant.id + 1

            get "/api/v1/merchants/#{invalid_merchant_id}/coupons/#{coupon.id}"
            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to eq("Merchant not found")
        end

        it "returns a 404 status if coupon does not belong to the specified merchant" do
            merchant = Merchant.create!(name: "cat store")
            other_merchant = Merchant.create!(name: "woof store")
            other_coupon = Coupon.create!(
                name: "Discount 10",
                code: "DISC10",
                discount_type: "dollar",
                discount_value: 10,
                status: true,
                merchant_id: other_merchant.id
            )

            get "/api/v1/merchants/#{merchant.id}/coupons/#{other_coupon.id}"

            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to eq("Coupon not found")
            expect(response.status).to eq(404)
        
        end
    end

    describe 'GET /api/v1/merchants/:merchant_id/coupons/:id' do
      it 'returns a specific coupon and shows a count of how many times it has been used' do
        merchant = Merchant.create!(name: "cat store")
        coupon = Coupon.create!(
          name: "$10 off",
          code: "10OFF",
          discount_type: "dollar",
          discount_value: 10,
          status: true,
          merchant_id: merchant.id
        )

        customer = Customer.create!(first_name: "Amalee", last_name: "Keunemany")
        
        3.times { Invoice.create!(
          merchant_id: merchant.id, 
          coupon: coupon, 
          status: 'completed', 
          customer: customer) }
  
        get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
        json_response = JSON.parse(response.body, symbolize_names: true)
  
        expect(response).to have_http_status(:ok)
        expect(json_response[:data][:id]).to eq(coupon.id.to_s)
        expect(json_response[:data][:type]).to eq("coupon")
        expect(json_response[:data][:attributes][:name]).to eq("$10 off")
        expect(json_response[:data][:attributes][:code]).to eq("10OFF")
        expect(json_response[:data][:attributes][:discount_type]).to eq("dollar")
        expect(json_response[:data][:attributes][:discount_value]).to eq(10)
        expect(json_response[:data][:attributes][:status]).to be true
        expect(json_response[:data][:attributes][:usage_count]).to eq(3) # usage count check
      end
    

    it 'returns a usage count of 0 if the coupon has not been used' do
      merchant = Merchant.create!(name: "cat store")
      coupon = Coupon.create!(
        name: "Discount 10",
        code: "DISC10",
        discount_type: "dollar",
        discount_value: 10,
        status: true,
        merchant_id: merchant.id
      )
    
      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:ok)
      expect(json_response[:data][:attributes][:usage_count]).to eq(0) # no usage
    end

    it 'returns a 404 status if the coupon does not belong to the specified merchant' do
      merchant = Merchant.create!(name: "cat store")
      other_merchant = Merchant.create!(name: "dog store")
      coupon = Coupon.create!(
        name: "Discount 10",
        code: "DISC10",
        discount_type: "dollar",
        discount_value: 10,
        status: true,
        merchant_id: other_merchant.id
      )
    
      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:not_found)
      expect(json_response[:error]).to eq("Coupon not found")
    end
  end
  