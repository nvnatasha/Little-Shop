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

merchant1 = Merchant.create(
  name: "The Cat Store",
)

# Create Coupons for Cat Store
merchant.coupons.create([
  {
    name: "$10 Off",
    code: "10OFF",
    discount_type: "dollar",
    discount_value: 10, # 20% off
    status: true
  },
  {
    name: "25% Off",
    code: "25PERCENT",
    discount_type: "percent",
    discount_value: 25, # 50% off
    status: true
  },
  {
    name: "50% Off",
    code: "50PERCENT",
    discount_type: "percent",
    discount_value: 50, # $10 off
    status: true
  },
  {
    name: "Adopt a Cat Discount",
    code: "ADOPT15",
    discount_type: "dollar",
    discount_value: 15, # $15 off adoption fee
    status: true
  }
])

# You can also create additional merchants and coupons for other cat-related businesses
merchant2 = Merchant.create(
  name: "Purrfect Cat Care",
)

merchant2t.coupons.create([
  {
    name: "$15 Off",
    code: "15OFF",
    discount_type: "dollar",
    discount_value: 15, # 20% off grooming services
    status: true
  },
  {
    name: "New Kitten Bundle",
    code: "NEWKITTEN",
    discount_type: "dollar",
    discount_value: 25, # $10 off kitten care
    status: true
  }
])

# Create an invoice and apply a coupon
invoice = Invoice.create(customer_id: 1, coupon: coupon1)
invoice.calculate_total
