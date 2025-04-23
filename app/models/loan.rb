class Loan < ApplicationRecord
  belongs_to :institution
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :repayments, dependent: :destroy  
  before_save :sync_status_with_approval
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :interest_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  belongs_to :institution
  validates :amount, :interest_rate, :due_date, presence: true
  # before_save :set_risk_level
  validates :loan_amount, :interest_rate, :loan_term, presence: true
  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }

  scope :search_by_transaction_id, ->(transaction_id) { joins(:transactions).where(transactions: { id: transaction_id }) }
  scope :repayments_id_eq, ->(id) { joins(:repayments).where(repayments: { id: id }) }
  def display_status
    return 'Repaid' if status == 'repaid'
    return 'Approved' if approved?
    return status.capitalize if status.present?
    'Pending'
  end

  def total_repayment_amount
    amount.to_f + (amount.to_f * interest_rate.to_f / 100)
  end

  def repaid?
    repaid_at.present?
  end
  
  def repay
    @loan = current_user.loans.find(params[:id])
  
    if @loan.approved? && !@loan.repaid?
      @loan.repay!
      flash[:notice] = "Loan repaid successfully."
    else
      flash[:alert] = "Loan cannot be repaid. Status: #{@loan.status}"
    end
  
    redirect_to loans_path
  end
  
  def total_repaid
    repayments.sum(:amount)
  end

  def remaining_balance
    total_repayment_amount - total_repaid
  end

  def check_if_fully_paid!
    update(status: :repaid) if remaining_balance <= 0
  end

  def self.ransackable_associations(auth_object = nil)
    super + ["user", "transactions", "repayments"]
  end

  def self.ransackable_attributes(auth_object = nil)
    super + ["amount", "created_at", "due_date", "id", "status", "updated_at", "user_id", "duration", "repayments_id_eq"]
  end

 def sync_status_with_approval
  self.status = :approved if approved? && status.blank?
end

def disburse_loan_from_smart_contract!(transaction_id)
  # Log the disbursement in the Rails model
  self.update(status: :approved)

  # Log transaction details, assuming `Transaction` is a model in your system
  Transaction.create!(loan_id: self.id, transaction_id: transaction_id, amount: self.amount, status: 'disbursed')
end

def process_repayment!(transaction_id, repayment_amount)
  # Record the repayment in the Rails model
  repayment = Repayment.create!(loan_id: self.id, amount: repayment_amount, transaction_id: transaction_id)

  # Update the total repaid amount
  update(status: :repaid) if remaining_balance <= 0
end
  private

  def set_risk_level
    return if credit_score.nil?

    self.risk_level = case credit_score
                      when 750..850 then "Low"
                      when 650..749 then "Medium"
                      else "High"
                      end
  end
end
