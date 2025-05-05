# require 'json'
# require 'net/http'
# require 'uri'

# class ExperianService
#   def self.get_token
#     # Return a mock token for practice
#     "mock_token_12345"
#   end

#   def self.fetch_credit_score(user)
#     # Stubbed response; replace with real Experian API call
#     {
#       credit_score: 715 # Example score
#     }
#   end
# end
class ExperianService
  def self.fetch_credit_score(user, loan_amount)
    income = user.monthly_income.to_f
    ratio = income / loan_amount.to_f

    score = if ratio < 0.3
              rand(300..500)
            elsif ratio < 0.7
              rand(501..650)
            else
              rand(651..850)
            end

    { score: score }
  end
end
