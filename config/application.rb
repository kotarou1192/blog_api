require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
require 'rails/test_unit/railtie'
require 'resolv'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TodoTree
  class Application < Rails::Application
    if Rails.env == 'development'
      # This also configures session_options for use below
      config.session_store :cookie_store, key: '_interslice_session'

      # Required for all session management (regardless of session_store)
      config.middleware.use ActionDispatch::Cookies

      config.middleware.use config.session_store, config.session_options
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    hosts_list = %w[api.takashiii-hq.com takashiii-hq.com takashiii-hq-api-production localhost]
    config.hosts.concat hosts_list

    config.active_job.queue_adapter = :sidekiq

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        # TODO: origin
        hosts_list << Resolv::DNS.new(nameserver: 'ns1.google.com').getresources('o-o.myaddr.l.google.com', Resolv::DNS::Resource::IN::TXT)[0].strings[0]
        origins hosts_list
        resource '*',
                 headers: :any,
                 methods: %i[:get, :post, :put, :delete, :options, :head]
      end
    end


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
