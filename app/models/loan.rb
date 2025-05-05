class Loan < ApplicationRecord
  belongs_to :institution
  before_validation :fetch_credit_score, on: :create
  before_create :assess_risk
  before_validation :set_contract_address, on: :create
  before_save :set_contract_address
  belongs_to :user
  has_many :transactions, dependent: :destroy
  has_many :repayments, dependent: :destroy
  before_create :assign_user_loan_id
  before_save :sync_status_with_approval
  before_create :assess_risk

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :institution_id, presence: true
  validates :monthly_income, presence: true, numericality: { only_integer: true }

  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    repaid: 'repaid'
  }

  scope :search_by_transaction_id, ->(transaction_id) { joins(:transactions).where(transactions: { id: transaction_id }) }
  scope :repayments_id_eq, ->(id) { joins(:repayments).where(repayments: { id: id }) }

  # Status display helper
  def display_status
    return 'Repaid' if repaid?
    return status.capitalize if status.present?
    'Pending'
  end

  def total_repayment_amount
    amount.to_f + (amount.to_f * interest_rate.to_f / 100)
  end

  def repaid?
    repaid_at.present?
  end


  def fetch_credit_score
    # Simulate fetching credit score from an external service
    self.credit_score ||= ExperianService.fetch_credit_score(user, amount)[:score]
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

  def loan_term
    duration
  end

  def loan_amount
    amount
  end

  # app/models/loan.rb

  def disburse_loan_from_smart_contract!(transaction_id)
    update!(status: :approved)
    transactions.create!(transaction_id: transaction_id, amount: amount, status: 'disbursed')
  end

  def process_repayment!(transaction_id, repayment_amount)
    repayments.create!(amount: repayment_amount, transaction_id: transaction_id)
    check_if_fully_paid!
  end

  def self.ransackable_associations(auth_object = nil)
    super + ["user", "transactions", "repayments"]
  end

  def self.ransackable_attributes(auth_object = nil)
    super + ["amount", "created_at", "due_date", "id", "status", "updated_at", "user_id", "duration", "repayments_id_eq"]
  end


  private
  def set_contract_address
    if institution
      self.contract_address = institution.contract_address
    else
      errors.add(:institution, "must have a contract address")
    end
  end


  def assign_user_loan_id
    last_id = user.loans.maximum(:user_loan_id) || 0
    self.user_loan_id = last_id + 1
  end
  
  def sync_status_with_approval
    self.status ||= 'pending'
  end
  def assess_risk
    self.credit_score ||= rand(300..800)
  
    monthly_installment = amount.to_f / duration.to_f
    income = monthly_income.to_f
  
    if credit_score >= 700
      self.risk_level = 'Low'
      self.status = 'approved'
    elsif credit_score >= 600
      self.risk_level = 'Medium'
      self.status = 'approved'
    elsif credit_score >= 500
      if monthly_installment < income * 0.5
        self.risk_level = 'Medium'
        self.status = 'approved'
      else
        self.risk_level = 'High'
        self.status = 'rejected'
      end
    else
      if monthly_installment < income * 0.3
        self.risk_level = 'Medium'
        self.status = 'approved'
      else
        self.risk_level = 'High'
        self.status = 'rejected'
      end
    end
  end  
  
end

