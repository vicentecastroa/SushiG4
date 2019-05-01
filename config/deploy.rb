# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "SushiG4"
set :repo_url, "https://github.com/vicentecastroa/SushiG4.git"

# Default branch is :master
set :branch, `git rev-parse --abbrev-ref DeploySetup`.chomp
# set :branch, ENV['BRANCH'] if ENV['BRANCH']

# Deploy to the user's home directory
set :deploy_to, "/home/deploy/#{fetch :application}"

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/SushiG4"

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
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", 'vendor/bundle', '.bundle', "public/system", 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :tmp_dir, "/home/deploy"

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
    
  task :seed do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env)  do
          execute :rake, 'db:seed'
        end
      end
    end
  end
  task :reset do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env)  do
          execute :rake, 'db:reset'
        end
      end
    end
  end
end

#namespace :sidekiq do
#  task :quiet do
#    on roles(:app) do
#      puts capture("pgrep -f 'sidekiq' | xargs kill -TSTP") 
#    end
#  end
#  task :restart do
#    on roles(:app) do
#      execute :sudo, :systemctl, :restart, :sidekiq
#    end
#  end
#end

#after 'deploy:starting', 'sidekiq:quiet'
#after 'deploy:reverted', 'sidekiq:restart'
#after 'deploy:published', 'sidekiq:restart'
