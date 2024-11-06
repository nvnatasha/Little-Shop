require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "relationships" do
    it { should have_many(:invoices)}
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'find_by_merchant' do
    it 'finds all unique customers for a merchant' do
      Invoice.destroy_all
      @merchant = Merchant.create!(name: "Merchant A")
      @customer = Customer.create!(first_name: "Natalia", last_name: "Vasquez")
      @customer2 = Customer.create!(first_name: "Jennifer", last_name: "Vasquez")
      @customer2 = Customer.create!(first_name: "Natalee", last_name: "Vasquez")
      @invoice1 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")
      @invoice2 = Invoice.create!(customer: @customer2, merchant: @merchant, status: "pending")
      @invoice3 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")

      customersForMerchant = Customer.find_by_merchant(@merchant.id)
      expect(customersForMerchant).to eq([@customer, @customer2])
    end
  end
end