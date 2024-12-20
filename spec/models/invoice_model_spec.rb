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
    end
  
    describe 'Validations and associations' do
      it 'creates a valid invoice with associated merchant and coupon' do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant)
      
        invoice = create(:invoice, merchant: merchant, coupon: coupon)
      
        expect(invoice).to be_valid
        expect(invoice.merchant).to eq(merchant)
        expect(invoice.coupon).to eq(coupon)
      end
  
      it 'creates a valid invoice without a coupon' do
        merchant = create(:merchant)
    
        invoice = create(:invoice, merchant: merchant, coupon: nil)
    
        expect(invoice).to be_valid
        expect(invoice.coupon).to be_nil
      end
      it 'is invalid without a merchant' do
        coupon = create(:coupon)
    
        invoice = build(:invoice, merchant: nil, coupon: coupon)
    
        expect(invoice).to_not be_valid
        expect(invoice.errors[:merchant]).to include("must exist")  # Adjust with the actual validation message
      end
      it 'correctly associates a coupon with the invoice' do
        merchant = create(:merchant)
        coupon = create(:coupon, merchant: merchant)
    
        invoice = create(:invoice, merchant: merchant, coupon: coupon)
    
        expect(invoice.coupon).to eq(coupon)
        expect(invoice.coupon.merchant).to eq(merchant)
      end
  
      it 'creates an invoice without a coupon' do
        merchant = create(:merchant)
    
        invoice = create(:invoice, merchant: merchant, coupon: nil)
    
        expect(invoice.coupon).to be_nil
      end
    end
  end

  describe '#calculate_total' do
  it 'sets the merchant total to $0 if the coupon’s discount exceeds the total cost of merchant items' do

    merchant = Merchant.create!(name: "cat store")
    

    coupon = Coupon.create!(
      name: "$15 Off",
      code: "15OFF",
      discount_type: "dollar",
      discount_value: 15, 
      status: true,
      merchant_id: merchant.id
    )
    
    item1 = Item.create!(name: "item1", description: "something for cats", unit_price: 5, merchant: merchant)
    item2 = Item.create!(name: "item2", description: "something for cats", unit_price: 3, merchant: merchant)
    
    invoice = Invoice.create!(merchant: merchant, customer: Customer.create!(first_name: "Amalee", last_name: "Keunemany"), coupon: coupon)


    invoice_item1 = InvoiceItem.create!(item: item1, invoice: invoice, quantity: 1, unit_price: 5)
    invoice_item2 = InvoiceItem.create!(item: item2, invoice: invoice, quantity: 2, unit_price: 3)


    invoice.invoice_items << [invoice_item1, invoice_item2]

    total = invoice.calculate_total

    expect(total).to eq(0)
  end
end
end



      