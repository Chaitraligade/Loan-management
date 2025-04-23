module Mutations
  class CreatePaymentIntent < BaseMutation
    argument :amount, Float, required: true

    field :client_secret, String, null: true
    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(amount:)
      user = context[:current_user]
      payment_intent = StripePaymentService.create_payment_intent((amount * 100).to_i, user)

      {
        client_secret: payment_intent.client_secret,
        success: true,
        errors: []
      }
    rescue => e
      {
        client_secret: nil,
        success: false,
        errors: [e.message]
      }
    end
  end
end
