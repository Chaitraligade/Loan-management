module Mutations
  class RepayLoan < BaseMutation
    argument :loan_id, ID, required: true
    argument :amount, Float, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(loan_id:, amount:)
      user = context[:current_user]
      loan = Loan.find_by(id: loan_id, user: user)

      return { success: false, errors: ["Loan not found"] } if loan.nil?

      StripePaymentService.charge(user, (amount * 100).to_i)

      loan.update!(repaid_amount: loan.repaid_amount + amount)

      { success: true, errors: [] }
    rescue => e
      { success: false, errors: [e.message] }
    end
  end
end
