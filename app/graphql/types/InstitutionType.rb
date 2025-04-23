module Types
  class InstitutionType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :loan_products, [Types::LoanProductType], null: true
  end
end
