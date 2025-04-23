module Mutations
  class CreateInstitution < BaseMutation
    argument :name, String, required: true

    field :institution, Types::InstitutionType, null: true
    field :errors, [String], null: false

    def resolve(name:)
      authorize_admin!

      institution = Institution.new(name: name, api_key: SecureRandom.hex)
      if institution.save
        { institution:, errors: [] }
      else
        { institution: nil, errors: institution.errors.full_messages }
      end
    end

    private

    def authorize_admin!
      raise GraphQL::ExecutionError, "Permission denied" unless context[:current_user]&.super_admin?
    end
  end
end
