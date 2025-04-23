# app/models/institution.rb
class Institution < ApplicationRecord
  has_many :users
  has_many :loans
  
  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]
  end
end
