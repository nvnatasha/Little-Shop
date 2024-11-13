require 'rails_helper'

RSpec.describe "Merchant Coupons API", type: :request do
    describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
        it "returns a specific coupon for a merchant" do
      
        merchant = Merchant.create!(name: "cat store")
    
        coupon = Coupon.create!(
            name: "Buy One Get One 50",
            code: "BOGO50",
            discount_type: "percent",
            discount_value: 50,
            status: true,
            merchant_id: merchant.id
        )
    
        get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"  
 
        expect(response).to have_http_status(:ok)
    
      
        json_response = JSON.parse(response.body, symbolize_names: true)
    
        
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
        expect(json_response[:data][:attributes][:usage_count]).to eq(3) 
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
      expect(json_response[:data][:attributes][:usage_count]).to eq(0) 
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
  
  
    it 'returns all coupons for a given merchant' do
  
      merchant = Merchant.create!(name: "Cat Store")
      coupon1 = Coupon.create!(
        name: "Buy One Get One 50",
        code: "BOGO50",
        discount_type: "percent",
        discount_value: 50,
        status: true,
        merchant_id: merchant.id
      )
      coupon2 = Coupon.create!(
        name: "25 Percent Sale",
        code: "SALE25",
        discount_type: "percent",
        discount_value: 25,
        status: true,
        merchant_id: merchant.id
      )
      coupon3 = Coupon.create!(
        name: "$10 Off",
        code: "10OFF",
        discount_type: "dollar",
        discount_value: 10,
        status: false,
        merchant_id: merchant.id
      )
  

      get "/api/v1/merchants/#{merchant.id}/coupons"
      json_response = JSON.parse(response.body, symbolize_names: true)
  
 
      expect(response).to have_http_status(:ok)
      expect(json_response[:data].length).to eq(3)  

      expect(json_response[:data][0][:id]).to eq(coupon1.id.to_s)
      expect(json_response[:data][0][:type]).to eq("coupon")
      expect(json_response[:data][0][:attributes][:name]).to eq("Buy One Get One 50")
      expect(json_response[:data][0][:attributes][:code]).to eq("BOGO50")
      expect(json_response[:data][0][:attributes][:discount_type]).to eq("percent")
      expect(json_response[:data][0][:attributes][:discount_value]).to eq(50)
  
      expect(json_response[:data][1][:id]).to eq(coupon2.id.to_s)
      expect(json_response[:data][1][:type]).to eq("coupon")
      expect(json_response[:data][1][:attributes][:name]).to eq("25 Percent Sale")
      expect(json_response[:data][1][:attributes][:code]).to eq("SALE25")
      expect(json_response[:data][1][:attributes][:discount_type]).to eq("percent")
      expect(json_response[:data][1][:attributes][:discount_value]).to eq(25)
  
      expect(json_response[:data][2][:id]).to eq(coupon3.id.to_s)
      expect(json_response[:data][2][:type]).to eq("coupon")
      expect(json_response[:data][2][:attributes][:name]).to eq("$10 Off")
      expect(json_response[:data][2][:attributes][:code]).to eq("10OFF")
      expect(json_response[:data][2][:attributes][:discount_type]).to eq("dollar")
      expect(json_response[:data][2][:attributes][:discount_value]).to eq(10)
    end

    it 'returns an empty array when the merchant has no coupons' do
      merchant = Merchant.create!(name: "Empty Store")
      get "/api/v1/merchants/#{merchant.id}/coupons"
      json_response = JSON.parse(response.body, symbolize_names: true)
    
      expect(response).to have_http_status(:ok)
      expect(json_response[:data]).to be_empty
    end  
  end

    describe 'POST /api/v1/merchants/:merchant_id/coupons' do
      it 'creates a new coupon for the merchant and returns the coupon details' do
        merchant = Merchant.create!(name: "Cat store")
        
        coupon_params = {
          coupon: {
            name: "Buy One Get One 50",
            code: "BOGO50",
            discount_type: "dollar",
            discount_value: 50,
            status: true
          }
        }
    
        post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params
    
        json_response = JSON.parse(response.body, symbolize_names: true)
    
        expect(response).to have_http_status(:created)
        expect(json_response[:data][:type]).to eq("coupon")
        expect(json_response[:data][:attributes][:name]).to eq("Buy One Get One 50")
        expect(json_response[:data][:attributes][:code]).to eq("BOGO50")
        expect(json_response[:data][:attributes][:discount_type]).to eq("dollar")
        expect(json_response[:data][:attributes][:discount_value]).to eq(50)
        expect(json_response[:data][:attributes][:status]).to be true
      end

      it 'returns an error when the coupon code is not unique' do
        merchant = Merchant.create!(name: "Cat Store")
 
        Coupon.create!(
          name: "Existing Coupon",
          code: "DUPLICATECODE",
          discount_type: "percent",
          discount_value: 10,
          status: true,
          merchant_id: merchant.id
        )

        coupon_params = {
          coupon: {
            name: "New Coupon",
            code: "DUPLICATECODE",  
            discount_type: "dollar",
            discount_value: 15,
            status: true
          }
        }
    
        post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params
    
        json_response = JSON.parse(response.body, symbolize_names: true)
    
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to eq("Code has already been taken")
      end    
end

describe 'PATCH /api/v1/merchants/:merchant_id/coupons/:id' do
    it 'deactivates the coupon and returns the updated coupon' do
    
      merchant = Merchant.create!(name: 'Cat store')
      coupon = Coupon.create!(
        name: 'Buy One Get One 50',
        code: 'BOGO50',
        discount_value: 50,
        discount_type: 'percent',
        status: true,
        merchant: merchant
      )

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
      json_response = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json_response[:data][:attributes][:status]).to eq(false)
      expect(json_response[:data][:attributes][:name]).to eq(coupon.name)
    end

      it 'returns an error indicating the coupon cannot be deactivated' do
       
        merchant = Merchant.create!(name: 'Cat store')
        coupon = Coupon.create!(
          name: '$10 Off',
          code: '10OFF',
          discount_value: 10,
          discount_type: 'dollar',
          status: true,
          merchant: merchant
        )
        pending_invoice = Invoice.create!(
          merchant: merchant,
          coupon: coupon,
          status: 'pending',
          customer: Customer.create!(first_name: "Amalee", last_name: "Keunemany")
        )
  
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
        json_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to eq('Cannot deactivate coupon with pending invoices')
      end

      it 'returns a 404 status if the coupon does not exist' do
       
        merchant = Merchant.create!(name: 'Cat Store')

        patch "/api/v1/merchants/#{merchant.id}/coupons/28" 
        json_response = JSON.parse(response.body, symbolize_names: true)

        expect(response).to have_http_status(:not_found)
        expect(json_response[:error]).to eq('Coupon not found')
      end

      it "activates an inactive coupon successfully" do
        merchant = Merchant.create!(name: "Cat store")
        coupon = merchant.coupons.create!(
          name: "$10 off", 
          code: "10OFF", 
          discount_value: 10, 
          discount_type: "dollar", 
          status: false)

        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:data][:id]).to eq(coupon.id.to_s)
        expect(json_response[:data][:attributes][:status]).to eq(true)
      end

      it "returns an error when the coupon does not exist" do
        merchant = Merchant.create!(name: "Cat store")

        patch "/api/v1/merchants/#{merchant.id}/coupons/9999/activate"

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:error]).to eq("Coupon not found")
      end

      it "returns an error when the merchant does not exist" do
        patch "/api/v1/merchants/9999/coupons/1/activate"

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:error]).to eq("Merchant not found")
      end

        it 'returns a not found status with an error message' do
          merchant = Merchant.create!(name: "Cat Store")
          coupon = merchant.coupons.create!(
            name: "10% off Cat Treats",
            code: "CAT10",
            discount_value: 10,
            discount_type: "percent",
            status: true
          )

        patch "/api/v1/merchants/99999/coupons/#{coupon.id}"
  
          # Test the response status and JSON error message
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)['error']).to eq('Merchant not found')
        end

describe "GET /api/v1/merchants/:merchant_id/coupons" do
    context "when filtered by active status" do
      it "returns only active coupons" do
        merchant = Merchant.create!(name: "Cat Store")
        active_coupon = merchant.coupons.create!(
          name: "10% off Cat Treats",
          code: "CAT10",
          discount_value: 10,
          discount_type: "percent",
          status: true
        )
        inactive_coupon = merchant.coupons.create!(
          name: "$5 off Cat Beds",
          code: "CATBED5",
          discount_value: 5,
          discount_type: "dollar",
          status: false
        )


        get "/api/v1/merchants/#{merchant.id}/coupons", params: { status: true }

        response_json = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(response_json['data'].size).to eq(1)
        expect(response_json['data'].first['attributes']['status']).to eq(true)
      end
    end

    context "when filtered by inactive status" do
      it "returns only inactive coupons" do
        merchant = Merchant.create!(name: "Cat Store")
        active_coupon = merchant.coupons.create!(
          name: "10% off Cat Treats",
          code: "CAT10",
          discount_value: 10,
          discount_type: "percent",
          status: true
        )
        inactive_coupon = merchant.coupons.create!(
          name: "$5 off Cat Beds",
          code: "CATBED5",
          discount_value: 5,
          discount_type: "dollar",
          status: false
        )

        get "/api/v1/merchants/#{merchant.id}/coupons", params: { status: false }

        response_json = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(response_json['data'].size).to eq(1)
        expect(response_json['data'].first['attributes']['status']).to eq(false)
      end
    end

    context "when status filter is invalid" do
      it "returns an error" do
        merchant = Merchant.create!(name: "Cat Store")
        active_coupon = merchant.coupons.create!(
          name: "10% off Cat Treats",
          code: "CAT10",
          discount_value: 10,
          discount_type: "percent",
          status: true
        )
        inactive_coupon = merchant.coupons.create!(
          name: "$5 off Cat Beds",
          code: "CATBED5",
          discount_value: 5,
          discount_type: "dollar",
          status: false
        )

        get "/api/v1/merchants/#{merchant.id}/coupons", params: { status: 'invalid_status' }

        response_json = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json['error']).to eq('Invalid status filter')
      end
    end

    context "when no status filter is passed" do
      it "returns all coupons" do
        merchant = Merchant.create!(name: "Cat Store")
        active_coupon = merchant.coupons.create!(
          name: "10% off Cat Treats",
          code: "CAT10",
          discount_value: 10,
          discount_type: "percent",
          status: true
        )
        inactive_coupon = merchant.coupons.create!(
          name: "$5 off Cat Beds",
          code: "CATBED5",
          discount_value: 5,
          discount_type: "dollar",
          status: false
        )

        get "/api/v1/merchants/#{merchant.id}/coupons"

        response_json = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(response_json['data'].size).to eq(2)
      end
    end
    
      context 'when coupon is successfully activated' do
        it 'returns a successful activation message with status 200' do
       
          merchant = Merchant.create(name: 'Merchant')
          coupon = merchant.coupons.create!(
            name: "10% off Cat Treats",
            code: "CAT10",
            discount_value: 10,
            discount_type: "percent",
            status: true
          )
    
          patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"
    
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['data']['attributes']['status']).to eq(true)
        end
      end
    end

    describe 'PATCH #activate' do
    context 'when coupon is successfully activated' do
      it 'activates the coupon and returns status 200' do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant)
  
       patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"
  
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']).to include('id' => coupon.id.to_s)
      end
    end
  end
  
  describe 'PATCH #activate' do
    context 'when coupon cannot be activated' do
      it 'returns an error message with status 422' do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant, status: false)
        
        allow_any_instance_of(Coupon).to receive(:update).and_return(false)
  
         patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}/activate"
  
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Coupon could not be activated')
      end
    end
  end
  
  describe 'PATCH #update' do
    context 'when coupon is successfully deactivated' do
      it 'deactivates the coupon and returns status 200' do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant, status: true)
  
       patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
  
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']).to include('id' => coupon.id.to_s)
      end
    end
  end
  
  describe 'PATCH #update' do
    context 'when coupon cannot be deactivated' do
      it 'returns an error message with status 422' do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant, status: true)
        
        allow_any_instance_of(Coupon).to receive(:update).and_return(false)
  
        patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
  
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Coupon could not be deactivated')
      end
    end
  end

  describe 'GET #index' do
  it 'returns an error when merchant_id is missing' do
    get '/api/v1/merchants/:merchant_id/coupons', params: { status: 'true' }
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)['error']).to eq("Couldn't find Merchant with 'id'=:merchant_id")
  end
end

  describe 'POST #create' do
    it 'returns an error when merchant_id is missing' do
      post '/api/v1/merchants/:merchant_id/coupons', params: { coupon: { name: 'New cat coupon', code: 'CAT', discount_type: 'percentage', discount_value: 10, status: true } }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq("Couldn't find Merchant with 'id'=:merchant_id")
    end
  end
end