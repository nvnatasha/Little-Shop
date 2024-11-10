class AddCouponIdToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :coupon_id, :integer
  end
end
