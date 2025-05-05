# app/services/ai_service.rb
class AiService
  def self.analyze(credit_score)
    case credit_score
    when 750..Float::INFINITY
      { score: credit_score, risk_level: "low" }
    when 600..749
      { score: credit_score, risk_level: "medium" }
    else
      { score: credit_score, risk_level: "high" }
    end
  end
end
