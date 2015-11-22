# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'Ammolist'
set :repo_url, 'git@github.com:munireusa/ammolist.git'
# Default branch is :master
 
 set :rvm_ruby_version, 'ruby-2.2.2'
 # Default deploy_to directory is /var/www/my_app_name
 set :deploy_to, '/home/ammo/test.ammolist.com/'

# Default value for :scm is :git
 set :scm, :git

# Default value for :format is :pretty
 #set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
#set :pty, true

# Default value for :linked_files is []
 set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
 set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
 set :keep_releases, 3
 
 set :slack_url, 'https://hooks.slack.com/services/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'
 set :slack_channel, '#deployment'
 set :slack_username, 'Deploy ammolist.com production'
 set :slack_emoji, ':smile:'

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
