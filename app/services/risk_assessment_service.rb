# class RiskAssessmentService
#   def self.assess(user, amount)
#     credit_score = FakeCreditScoreService.fetch_credit_score(user)[:credit_score]
#     income = user.monthly_income
  
#     if credit_score.nil? || income.nil? || amount.nil?
#       return { score: credit_score || 0, risk_level: "Unknown" }
#     end
  
#     risk_level = if credit_score > 700 && income > 3000 && amount < 50000
#       "Low"
#     elsif credit_score > 600 && income > 2000 && amount < 100000
#       "Medium"
#     else
#       "High"
#     end
  
#     { score: credit_score, risk_level: risk_level }
#   end
  
# end
class RiskAssessmentService
  # Factor Weights
  CREDIT_SCORE_WEIGHT = 0.5
  INCOME_WEIGHT = 0.3
  LOAN_AMOUNT_WEIGHT = 0.2

  def self.assess(user, amount)
    credit_score = FakeCreditScoreService.fetch_credit_score(user)[:credit_score]
    income = user.monthly_income

    # Early return if any essential value is missing
    return { score: credit_score || 0, risk_level: "Unknown" } if credit_score.nil? || income.nil? || amount.nil?

    # Normalize the values (assuming 300-850 credit score range)
    normalized_credit_score = normalize_credit_score(credit_score)
    normalized_income = normalize_income(income)
    normalized_loan_amount = normalize_loan_amount(amount)

    # Calculate total risk score
    total_score = (normalized_credit_score * CREDIT_SCORE_WEIGHT) +
                  (normalized_income * INCOME_WEIGHT) +
                  (normalized_loan_amount * LOAN_AMOUNT_WEIGHT)

    # Determine risk level based on the total score
    risk_level = case total_score
                 when 0..0.4 then "High"
                 when 0.4..0.7 then "Medium"
                 else "Low"
                 end

    { score: credit_score, risk_level: risk_level }
  end

  private

  # Normalize credit score (higher = better)
  def self.normalize_credit_score(score)
    [(score - 300) / 550.0, 1.0].min # Return value between 0 and 1
  end

  # Normalize income (higher = better)
  def self.normalize_income(income)
    [(income - 1000) / 20000.0, 1.0].min # Assuming minimum income is 1000 and max income is 20000
  end

  # Normalize loan amount (lower = better for risk)
  def self.normalize_loan_amount(amount)
    [(50000 - amount) / 50000.0, 1.0].min # Loan amounts above 50000 increase risk
  end
end
