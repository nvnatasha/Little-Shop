class Invoice < ApplicationRecord
  belongs_to :merchant
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items

  before_validation :set_default_status

  validates :merchant, :customer, :status, presence: true

  def self.by_merchant(merchant_id)
    where(merchant_id: merchant_id)
  end

  def self.by_customer(customer_id)
    where(customer_id: customer_id)
  end

  def self.valid_merchant?(merchant_id)
    Merchant.exists?(merchant_id)
  end

  def valid_invoice?
    valid? 
  end

  private
  def set_default_status
    self.status ||= 'pending'
  end
end