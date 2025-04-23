# app/services/fake_credit_score_service.rb
class FakeCreditScoreService
  def self.fetch_credit_score(user)
    # Return a fake credit score between 300 and 850
    {
      credit_score: rand(300..850) # Random number between 300 and 850
    }
  end
end
