class Repayment < ApplicationRecord
  belongs_to :loan

  enum status: { pending: 0, paid: 1, late: 2 }

  validates :due_date, :amount, presence: true

end
