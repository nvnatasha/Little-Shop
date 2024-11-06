require 'rails_helper'

RSpec.describe 'Customers API', type: :request do
  before(:each) do

      @merchant1 = Merchant.create!(name: "Merchant 1")
      @merchant2 = Merchant.create!(name: "Merchant 2")

      @customer1 = Customer.create!(first_name: "Lisa", last_name: "Reeve")
      @customer2 = Customer.create!(first_name: "Michelle", last_name: "Plank")
      @customer3 = Customer.create!(first_name: "Karie", last_name: "Butterfield")
      @customer4 = Customer.create!(first_name: "Cathy", last_name: "Rojas")

      @invoice1 = Invoice.create!(merchant: @merchant1, customer: @customer1)
      @invoice2 = Invoice.create!(merchant: @merchant1, customer: @customer2, status: 'completed')
      @invoice3 = Invoice.create!(merchant: @merchant1, customer: @customer2, status: 'returned')
      
  end

  it 'can return customers' do
    get "/api/v1/merchants/#{@merchant1[:id]}/customers"

    expect(response).to be_successful
    customers = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(customers.count).to eq(2)

    customers.each do |customer|
        expect(customer).to have_key(:id)
        expect(customer[:id]).to be_a(String)
        expect(customer[:attributes]).to have_key(:first_name)
        expect(customer[:attributes][:first_name]).to be_a(String)
        expect(customer[:attributes]).to have_key(:last_name)
        expect(customer[:attributes][:last_name]).to be_a(String)
    end
  end

  it 'returns an empty array when no customers are associated with the merchant' do
    other_merchant = Merchant.create!(name: "Merchant 3")
    get "/api/v1/merchants/#{other_merchant[:id]}/customers"

    expect(response).to be_successful 
    customers = JSON.parse(response.body, symbolize_names: true)[:data]
    expect(customers).to eq([])
  end

  it 'returns a successful response and correct customer data format' do
    get "/api/v1/merchants/#{@merchant1[:id]}/customers"

    expect(response).to be_successful
    customers = JSON.parse(response.body, symbolize_names: true)[:data]

    customers.each do |customer|
      expect(customer).to be_a(Hash)
      expect(customer).to have_key(:id)
      expect(customer[:id]).to be_a(String) 
      expect(customer[:attributes]).to be_a(Hash)
      expect(customer[:attributes]).to have_key(:first_name)
      expect(customer[:attributes][:first_name]).to be_a(String)
      expect(customer[:attributes]).to have_key(:last_name)
      expect(customer[:attributes][:last_name]).to be_a(String)
  end
end

  it 'returns all invoices for a merchant\'s customers' do
    get "/api/v1/merchants/#{@merchant1[:id]}/invoices"

    expect(response).to be_successful
    invoices = JSON.parse(response.body, symbolize_names: true)[:data]    
    expect(invoices.count).to eq(3)
    invoice_statuses = invoices.map { |invoice| invoice[:attributes][:status] }
    expect(invoice_statuses).to include('pending', 'completed')
  end
end