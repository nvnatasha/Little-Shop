class Merchant < ApplicationRecord
  validates :name, presence: true
 get_all_merchants_with_returned_items
  has_many :invoices


  has_many :items, dependent: :destroy
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
end