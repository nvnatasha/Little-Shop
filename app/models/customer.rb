class Customer < ApplicationRecord
  has_many :invoices

  validates :first_name, presence: true
  validates :last_name, presence: true

  def self.find_by_merchant(merchant_id)
    invoices = Invoice.where(merchant_id: merchant_id)
    invoices.map(&:customer).uniq
  end
end