class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  has_many :customers
  has_many :coupons

  def self.queried(params)
    merchants = Merchant.all

    if params[:count] == 'true'
      merchants = merchants.includes(:items)
    end
  
    merchants = sort(params) if params[:sorted].present? || params[:status].present?
    merchants
  end

  def item_count
    items.count
  end
  

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

  def self.find_by_params(params)
    if params.has_key?(:name) && params[:name].present?
      merchant = Merchant.where('name ILIKE ?', "%#{params[:name]}%").first
      merchant || { error: { message: "No merchant found", status: 404 } }
    else
      { error: { message: "you need to specify a name", status: 404 } }
    end
  end

  def coupons_filtered_by_status(status = nil)
    if status == 'active'
      coupons.where(active: true) # Assuming you have an 'active' attribute in your coupons table
    elsif status == 'inactive'
      coupons.where(active: false) # Assuming inactive coupons have active: false
    else
      coupons # Return all coupons if no status is specified
    end
  end

  def coupons_count
    coupons.count
  end

  def invoice_coupon_count
    invoices.where.not(coupon_id: nil).count
  end
end
