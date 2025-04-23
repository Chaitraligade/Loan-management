# app/services/ai_service.rb
class AiService
  def self.analyze(credit_data)
    # Dummy AI logic for practice
    score = credit_data.to_i rescue 600
    risk_level = if score >= 750
                   "low"
                 elsif score >= 600
                   "medium"
                 else
                   "high"
                 end

    { score: score, risk_level: risk_level }
  end
end
