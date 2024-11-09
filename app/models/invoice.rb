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
    merchant_items_total = items.where(merchant_id: coupon.merchant_id).sum(:price)

    if coupon.present?
      if coupon.discount_type == "dollar"
        discounted_total = [merchant_items_total - coupon.discount_value, 0].max
      elsif coupon.discount_type == "percent"
        discounted_total = merchant_items_total * (1 - coupon.discount_value / 100.0)
      end
    else
      discounted_total = merchant_items_total
    end

    update(total: discounted_total)
  end


  private

  def set_default_status
    self.status ||= 'pending'
  end
  
end