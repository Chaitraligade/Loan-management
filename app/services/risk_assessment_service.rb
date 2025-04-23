class RiskAssessmentService
  def self.assess(user, loan)
    credit_score = FakeCreditScoreService.fetch_credit_score(user)[:credit_score]
    income = user.monthly_income
    amount = loan.amount

    if credit_score.nil? || income.nil? || amount.nil?
      return { score: credit_score || 0, risk_level: "Unknown" }
    end

    risk_level =
      if credit_score >= 700 && income > amount * 2
        "Low"
      elsif credit_score >= 600
        "Medium"
      else
        "High"
      end

    { score: credit_score, risk_level: risk_level }
  end
end
