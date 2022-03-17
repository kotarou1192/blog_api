namespace :cors do
  desc 'allow localhost:8080'
  task :allow_local do
    ENV['ALLOW_LOCAL'] = 'yes'
    invoke 'puma:stop'
    invoke! 'puma:start'
  end
end

namespace :cors do
  desc 'deny localhost:8080'
  task :deny_local do
    ENV['ALLOW_LOCAL'] = 'no'
    invoke 'puma:stop'
    invoke! 'puma:start'
  end
end
