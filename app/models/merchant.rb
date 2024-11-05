class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices


  has_many :items, dependent: :destroy

  def self.queried(params)
    merchants = Merchant.all
    merchants = Merchant.sort(params)
    merchants = params[:count] == 'true' ? Merchant.with_item_count : merchants
    merchants
  end
  has_many :customers

  def self.sort(params)
    if params[:sorted] == "age"
      Merchant.all.order(id: :desc)
    elsif params[:status] == "returned"
      Merchant.joins(:invoices).where("invoices.status = 'returned'")
    else
      Merchant.all
    end
  end

  def self.getMerchant(params)
    if params[:item_id]
      begin
        item = Item.find(params[:item_id])
        item.merchant
      rescue ActiveRecord::RecordNotFound => error
        error.message
      end
    else
      begin
        Merchant.find(params[:id])
      rescue ActiveRecord::RecordNotFound => error
        error.message
      end
    end
  end

  def self.with_item_count
      select("merchants.*, COUNT(items.id) AS item_count")
        .left_joins(:items)
        .group("merchants.id")
        
  end
end

