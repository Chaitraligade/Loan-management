# frozen_string_literal: true

module Types
  class LoanType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, Integer, null: false
    field :amount, Float
    field :status, String
    # field :interestRate, Float, null: false, method: :interest_rate
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: true
    field :duration, Integer, null: false
  end
end
