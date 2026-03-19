class User < ApplicationRecord
  has_secure_password
  has_many :llm_interactions, dependent: :destroy
  has_many :resumes, dependent: :destroy
  has_many :sessions, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, validate: true

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_salt&.last(10)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  before_validation :assign_initial_role, on: :create

  validates :email_address, presence: true, uniqueness: true

  def display_name
    email_address.split("@").first.humanize
  end

  private
    def assign_initial_role
      self.role = User.where.not(id: id).none? ? :admin : :user if role.blank?
    end
end
