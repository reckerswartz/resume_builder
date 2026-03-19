require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'callbacks' do
    it 'assigns the first user as admin and later users as standard users when role is blank' do
      first_user = described_class.create!(
        email_address: 'first@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        role: nil
      )

      second_user = described_class.create!(
        email_address: 'second@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        role: nil
      )

      expect(first_user.admin?).to be(true)
      expect(second_user.user?).to be(true)
    end
  end

  describe '#display_name' do
    it 'humanizes the local part of the email address' do
      user = build(:user, email_address: 'alex_morgan@example.com')

      expect(user.display_name).to eq('Alex morgan')
    end
  end
end
