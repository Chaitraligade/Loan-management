# app/models/institution.rb
class Institution < ApplicationRecord
  before_save :validate_contract_address
  has_many :users
  has_many :loans
  has_many :loans, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]
  end

  private 
  def validate_contract_address
    self.contract_address = contract_address.strip if contract_address.present?
  end
end
