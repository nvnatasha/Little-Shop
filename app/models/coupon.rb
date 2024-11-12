class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :merchant, presence:{ message: "must exist" }
    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :discount_type, presence: true, inclusion: { in: ["percent", "dollar"] }
  
    validate :active_coupon_limit, on: :create
  
    scope :active, -> { where(status: true) }
    scope :inactive, -> { where(status: false) }
  
    def active_coupon_limit
      return if merchant.nil? 
    
      if merchant.coupons.active.count >= 5
        errors.add(:base, "Merchant can't have more than 5 active coupons") 
      end
    end
    
    def usage_count
      invoices.count
    end
  end
