require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      session = create(:session)

      expect(session.user).to be_a(User)
      expect(session.user).to be_persisted
    end
  end

  describe 'validations' do
    it 'requires a user reference' do
      session = described_class.new(user: nil, ip_address: '127.0.0.1', user_agent: 'Mozilla/5.0')

      expect(session).not_to be_valid
      expect(session.errors[:user]).to be_present
    end
  end

  describe 'factory' do
    it 'creates a valid session with default attributes' do
      session = create(:session)

      expect(session).to be_persisted
      expect(session.ip_address).to be_present
      expect(session.user_agent).to be_present
    end
  end
end
