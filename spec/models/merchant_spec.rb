require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "relationships" do
    it { should have_many(:items)}
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "sort" do
    before :each do
      @merchant1 = Merchant.create(name: 'Wally')
      @merchant2 = Merchant.create(name: 'James')
      @merchant3 = Merchant.create(name: 'Natasha')
      @merchant4 = Merchant.create(name: 'Jonathan')
    end
    it "can sort merchants based on age" do
      merchants = Merchant.sort({sorted: "age"})

      expect(merchants[0].created_at).to be > (merchants[1].created_at)
      expect(merchants[1].created_at).to be > (merchants[2].created_at)
      expect(merchants[2].created_at).to be > (merchants[3].created_at)
    end

    it "ignores sort if not passed as a parameter" do
      merchants = Merchant.sort({nonsense: "Fun nonsense"})
      expect(merchants[0].created_at).to be < (merchants[1].created_at)
      expect(merchants[1].created_at).to be < (merchants[2].created_at)
      expect(merchants[2].created_at).to be < (merchants[3].created_at)
    end
  end
end