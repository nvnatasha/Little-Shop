# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)

merchant = Merchant.create(name: "Local Market")
coupon1 = merchant.coupons.create(name: "10% Off", code: "SAVE10", discount_type: "percent", discount_value: 10, status: true)
coupon2 = merchant.coupons.create(name: "$5 Off", code: "FIVEOFF", discount_type: "dollar", discount_value: 5, status: true)

# Create an invoice and apply a coupon
invoice = Invoice.create(customer_id: 1, coupon: coupon1)
invoice.calculate_total
