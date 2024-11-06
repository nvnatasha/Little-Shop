require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to(:customer) }
    it { should belong_to(:merchant) }
    it { should have_many(:transactions)}
    it { should have_many(:invoice_items)}
  end

  describe 'class methods' do
    before(:each) do
      Invoice.destroy_all
      @merchant = Merchant.create!(name: "Merchant A")
      @other_merchant = Merchant.create!(name: "Merchant B")
      @customer = Customer.create!(first_name: "Lisa", last_name: "Reeve")
      @invoice1 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")
      @invoice2 = Invoice.create!(customer: @customer, merchant: @merchant, status: "pending")
      @invoice3 = Invoice.create!(customer: @customer, merchant: @merchant, status: "completed")
      @other_invoice = Invoice.create!(customer: @customer, merchant: @other_merchant, status: "completed")
    end

    describe '.by_merchant' do
      it 'returns all invoices associated with the given merchant' do
        expect(Invoice.by_merchant(@merchant.id)).to include(@invoice1, @invoice2, @invoice3)
      end

      it 'does not return invoices from other merchants' do
        other_invoice = Invoice.create!(customer: @customer, merchant: @other_merchant, status: "completed")

        expect(Invoice.by_merchant(@merchant.id)).not_to include(other_invoice)
      end
    end

    describe '.by_customer' do
      it 'returns all invoices associated with the given customer' do
        expect(Invoice.by_customer(@customer.id)).to include(@invoice1, @invoice2, @invoice3)
      end
    end

    describe 'filter' do
      it 'returns filtered based on merchant' do
        invoices = Invoice.filter({merchant_id: @merchant.id})
        expect(invoices).to eq([@invoice1, @invoice2, @invoice3])
      end

      it 'returns filtered based on merchant and status' do
        invoices = Invoice.filter({merchant_id: @merchant.id, status: "completed"})
        expect(invoices).to eq([@invoice1, @invoice3])
      end

      it 'returns an empty array when no invoices exist' do
        other_merchant2 = Merchant.create!(name: "Merchant C")
        invoices = Invoice.filter({merchant_id: other_merchant2.id})
        expect(invoices).to eq([])
      end

      xit 'returns an error when the merchant does not exist' do
        expect(true).to eq(false)
      end
    end
  end
end