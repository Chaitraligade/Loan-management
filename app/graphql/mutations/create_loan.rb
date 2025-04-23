# app/graphql/mutations/create_loan.rb
module Mutations
  class CreateLoan < BaseMutation
    field :loan, Types::LoanType, null: true
    field :errors, [String], null: false

    argument :input, Types::LoanInputType, required: true

    def resolve(input:)
      loan = Loan.new(
        amount: input[:amount],
        duration: input[:duration],
        status: "pending",
        user: context[:current_user]
      )

      if loan.save
        { loan: loan, errors: [] }
      else
        { loan: nil, errors: loan.errors.full_messages }
      end
    end
  end
end
