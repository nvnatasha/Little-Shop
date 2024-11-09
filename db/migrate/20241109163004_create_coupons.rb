class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.string :discount_type
      t.integer :discount_value
      t.boolean :status
      t.integer :merchant_id

      t.timestamps
    end
  end
end
