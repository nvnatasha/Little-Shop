require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
      it { should belong_to(:customer) }
      it { should belong_to(:merchant) }
  end
end