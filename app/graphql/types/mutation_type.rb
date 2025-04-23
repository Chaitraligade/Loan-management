# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_loan, mutation: Mutations::CreateLoan
    field :approve_loan, mutation: Mutations::ApproveLoan
    # field :repay_loan, mutation: Mutations::RepayLoan
    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World"
    end
    field :assess_risk, mutation: Mutations::AssessRisk
    field :repay_loan, mutation: Mutations::RepayLoan
    field :create_payment_intent, mutation: Mutations::CreatePaymentIntent

  end
end
