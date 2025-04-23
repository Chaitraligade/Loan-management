class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :loan

  def self.ransackable_attributes(auth_object = nil)
    ["action", "created_at", "error_message", "id", "id_value", "loan_id", "status", "tx_hash", "updated_at", "user_id"]
  end
end
