# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "todo_tree_api"
set :repo_url, "https://github.com/kotarou1192/todo_tree_api.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# 共有する設定ファイル
append :linked_files, 'config/environments/production.rb', 'config/database.yml', 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets"

set :rbenv_type, :user
set :rbenv_custom_path, '/home/rails/.rbenv'
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} RAILS_ENV=production #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails]
set :rbenv_roles, :all
# set :rbenv_custom_path, '/home/rails/.rbenv'

# bundlerの設定
append :linked_dirs, '.bundle'
set :bundle_jobs, 1

# pumaコマンドをbundle execで実行
append :rbenv_map_bins, 'puma', 'pumactl'

namespace :deploy do
  task :restart_puma do
    invoke 'puma:stop'
    invoke! 'puma:start'
  end
end

namespace :deploy do
  desc "Restart sidekiq"
  task :restart_sidekiq do
    on roles(:app), in: :sequence, wait: 5 do
      execute :sudo, :systemctl, :restart, :sidekiq
    end
  end

  after :finishing, 'deploy:restart_sidekiq'
end
