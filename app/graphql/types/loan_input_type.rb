# app/graphql/types/loan_input_type.rb
module Types
  class LoanInputType < BaseInputObject
    argument :amount, Float, required: true
    argument :duration, Integer, required: true
  end
end
