module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :email, String, null: false
    field :name, String, null: true
    field :role, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # If you want to expose loans or institution, include:
    # field :loans, [Types::LoanType], null: true
    # field :institution, Types::InstitutionType, null: true
  end
end
