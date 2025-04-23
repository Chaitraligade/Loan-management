require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LoanManagement
  class Application < Rails::Application
    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [
      :application, :controller, :action, :job,
      current_graphql_operation: -> { GraphQL::Current.operation_name },
      current_graphql_field: -> { GraphQL::Current.field&.path },
      current_dataloader_source: -> { GraphQL::Current.dataloader_source_class },
    ]

    config.load_defaults 7.1

    config.autoload_lib(ignore: %w(assets tasks))

    config.api_only = false

    # Re-enable sessions and cookies for Devise
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_loan_management_session'

    # Load environment variables
    require 'dotenv'
    Dotenv.load
    Dotenv::Railtie.load

    # Disable Sprockets (not needed if using importmaps or webpacker)
   

    # Enable Webpacker support (if you're using it alongside importmap)
    config.use_webpacker = true

    # Importmap config (if you are using it)
    # config.importmap.draw do
    #   pin "activeadmin", to: "https://cdn.jsdelivr.net/npm/activeadmin@3.2.5/dist/active_admin.min.js"
    # end
  end
end
