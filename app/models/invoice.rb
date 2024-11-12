class Invoice < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  belongs_to :coupon, optional: true
  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy

  before_validation :set_default_status

  validates :merchant, :customer, :status, presence: true

  def self.filter(params)
    merchant = Merchant.find(params[:merchant_id])
    if params.include?(:status)
      invoices = Invoice.where(merchant_id: params[:merchant_id], status: params[:status])
    else 
      invoices = Invoice.where(merchant_id: params[:merchant_id])
    end
  end

  def self.by_merchant(merchant_id)
    where(merchant_id: merchant_id)
  end

  def self.by_customer(customer_id)
    where(customer_id: customer_id)
  end

  def calculate_total
    total = 0
    invoice_items.group_by { |invoice_item| invoice_item.item.merchant }.each do |merchant, items|
      # Calculate merchant total, making sure unit_price and quantity are not nil
      merchant_items_total = items.sum { |item| (item.unit_price || 0) * (item.quantity || 0) }
    
      # Apply coupon if available
      if coupon.present? && coupon.merchant_id == merchant.id
        discount_amount = coupon.discount_value  # Ensure this is the correct discount field
  
        merchant_items_total -= discount_amount
        merchant_items_total = [merchant_items_total, 0].max # Prevent negative total
      end
    
      total += merchant_items_total
    end
  
    total
  end
  private

  def set_default_status
    self.status ||= 'pending'
  end
  
end