module Types
  class LoanProductType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :interest_rate, Float, null: false
    field :duration, Integer, null: false
    field :max_amount, Float, null: false
    field :institution, Types::InstitutionType, null: false
  end
end
