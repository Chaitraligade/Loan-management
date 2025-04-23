module Mutations
  class ApproveLoan < BaseMutation
    argument :loan_id, ID, required: true

    field :loan, Types::LoanType, null: true
    field :errors, [String], null: false

    def resolve(loan_id:)
      admin = context[:current_user]
      loan = Loan.find(loan_id)

      service = Blockchain::LoanContractService.new
      service.approve_loan(loan.blockchain_loan_id)

      loan.update!(status: "approved")

      { loan: loan, errors: [] }
    rescue => e
      { loan: nil, errors: [e.message] }
    end
  end
end
