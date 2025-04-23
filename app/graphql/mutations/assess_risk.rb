module Mutations
  class AssessRisk < BaseMutation
    argument :loan_id, ID, required: true

    field :credit_score, Integer, null: true
    field :risk_level, String, null: true
    field :errors, [String], null: false

    def resolve(loan_id:)
      user = context[:current_user]
      loan = Loan.find_by(id: loan_id)

      return { credit_score: nil, risk_level: nil, errors: ["Loan not found"] } if loan.nil?

      result = RiskAssessmentService.assess(user, loan)

      {
        credit_score: result[:score],
        risk_level: result[:risk_level],
        errors: []
      }
    rescue => e
      {
        credit_score: nil,
        risk_level: nil,
        errors: [e.message]
      }
    end
  end
end
