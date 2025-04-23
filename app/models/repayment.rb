class Repayment < ApplicationRecord
  belongs_to :loan
  belongs_to :user
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_at, presence: true
  after_create :update_loan_status
  validates :user_id, presence: true
  validates :loan_id, presence: true
  
  def self.ransackable_attributes(auth_object = nil)
    ["amount", "created_at", "id", "loan_id", "paid_at", "updated_at", "user_id"]
  end
  private

  def update_loan_status
    loan.check_if_fully_paid!
  end

end
