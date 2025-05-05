class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         has_many :notifications, dependent: :destroy
  has_many :transactions
  has_many :loans, dependent: :destroy
  belongs_to :institution, optional: true
  enum role: { borrower: 0, institution_admin: 1, super_admin: 2 }

  def admin?
    self.admin  # returns true if the user is an admin, false otherwise
  end

  # Allow Ransack to search through these attributes
  def self.ransackable_attributes(auth_object = nil)
    [
      "email", "admin", "name", "role", "created_at", "updated_at", 
      "institution_id", "credit_score", "monthly_income", "risk_level", 
      "eth_address", "id_value"
    ]
  end

  # Allow Ransack to search through these associations
  def self.ransackable_associations(auth_object = nil)
    # Explicitly list associations you want to allow for searching
    ["institution", "loans", "transactions"]
  end
end
