config.middleware.insert_before 0, Rack::Cors do
  allow do
    # TODO: origin
    hosts_list << Resolv::DNS.new(nameserver: 'ns1.google.com').getresources('o-o.myaddr.l.google.com', Resolv::DNS::Resource::IN::TXT)[0].strings[0]
    origins 'https://api.takashiii-hq.com', 'https://takashiii-hq.com'
    resource '*',
             headers: :any,
             methods: %i[:get, :post, :put, :delete, :options, :head]
  end
end
