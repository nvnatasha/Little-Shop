class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  validates :merchant_id, presence: true
  has_many :invoice_items, dependent: :destroy
  belongs_to :merchant

  def self.getItems(params = {})
    if params[:sorted] == 'price'
      Item.all.order(:unit_price)
    elsif params.key?(:id)
      begin
        merchant = Merchant.find(params[:id])
        Item.all.where("merchant_id = #{merchant.id}")
      rescue ActiveRecord::RecordNotFound => error
        error.message
      end
    else
      Item.all
    end
  end

  def self.find_all(params = {})
    if  params.has_key?(:name) && (params.has_key?(:max_price) || params.has_key?(:min_price))
      { error: { message: "you can't ask for both", status: 405 } }
    elsif params.has_key?(:name)
      items = Item.where('name ILIKE ?', "%#{params[:name]}%") 
    elsif params.has_key?(:max_price) && params.has_key?(:min_price)
      items = Item.where("unit_price between ? and ?", params[:min_price], params[:max_price])
    elsif params.has_key?(:min_price)
      items = Item.where("unit_price > ?", params[:min_price])
    elsif params.has_key?(:max_price)
      items = Item.where("unit_price < ?", params[:max_price])
    end
  end
end