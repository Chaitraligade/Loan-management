module Mutations
  class ApplyForLoan < BaseMutation
    argument :loan_product_id, ID, required: true
    argument :amount, Float, required: true

    field :loan, Types::LoanType, null: true
    field :errors, [String], null: false

    def resolve(loan_product_id:, amount:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.borrower?

      loan_product = LoanProduct.find(loan_product_id)
      loan = user.loans.new(
        amount: amount,
        interest_rate: loan_product.interest_rate,
        duration: loan_product.duration,
        institution: loan_product.institution
      )

      if loan.save
        { loan:, errors: [] }
      else
        { loan: nil, errors: loan.errors.full_messages }
      end
    end
  end
end
