class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice

  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :merchant_id, presence: true
end
