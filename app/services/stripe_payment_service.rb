class StripePaymentService
  def self.create_payment_intent(amount, user)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    Stripe::PaymentIntent.create({
      amount: amount.to_i,
      currency: 'usd',
      metadata: { user_id: user.id }
    })
  end
end
