Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # TODO: origin
    origins '*'
    resource '*',
             headers: :any,
             methods: %i[:get, :post, :put, :delete, :options, :head]
  end
end
