require 'rails_helper'

RSpec.describe InvoiceSerializer do
  describe '.format_invoice' do
    it 'returns a hash with the correct structure' do
        merchant = Merchant.create(name: "cat store")
        customer = Customer.create(first_name: "Amalee", last_name: "Keunemany")
      invoice = create(:invoice, status: "completed", merchant_id: "#{merchant.id}", customer_id: "#{customer.id}", coupon_id: 3)
      formatted_data = described_class.format_invoice(invoice)

      expect(formatted_data).to be_a(Hash)
      expect(formatted_data).to have_key(:data)

      data = formatted_data[:data]
      expect(data).to be_a(Hash)
      expect(data).to have_key(:id)
      expect(data).to have_key(:type)
      expect(data).to have_key(:attributes)

      expect(data[:id]).to eq(invoice.id.to_s)
      expect(data[:type]).to eq('invoice')
    end

    it 'returns the correct attributes for the invoice' do
      merchant = Merchant.create(name: "cat store")
      customer = Customer.create(first_name: "Amalee", last_name: "Keunemany")
      invoice = create(:invoice, status: "completed", merchant_id: "#{merchant.id}", customer_id: "#{customer.id}", coupon_id: 3)
      formatted_data = described_class.format_invoice(invoice)
      attributes = formatted_data[:data][:attributes]

      expect(attributes[:status]).to eq(invoice.status)
      expect(attributes[:merchant_id]).to eq(invoice.merchant_id)
      expect(attributes[:customer_id]).to eq(invoice.customer_id)
      expect(attributes[:coupon_id]).to eq(invoice.coupon_id)
    end

    it 'returns nil for coupon_id if no coupon is associated' do
      invoice_without_coupon = create(:invoice, coupon_id: nil)
      formatted_data = described_class.format_invoice(invoice_without_coupon)
      attributes = formatted_data[:data][:attributes]


      expect(attributes[:coupon_id]).to be_nil
    end
  end
end
  

