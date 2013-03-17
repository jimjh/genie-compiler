require 'rvm/capistrano'
require 'bundler/capistrano'

set :application, 'genie-compiler'
set :repository,  'git@github.com:jimjh/genie-compiler.git'
set :user,        'passenger'

set :scm,        :git
set :deploy_via, :remote_cache
set :use_sudo,   false

set :rvm_ruby_string, 'ruby-1.9.3-p362'
set :rvm_type,        :system

role :app, 'beta.geniehub.org'

after 'deploy:restart', 'deploy:cleanup'
after 'deploy:setup',   'deploy:upstart'

namespace :deploy do
  task :upstart do
    location = fetch(:template_dir, 'config/deploy') + '/lamp.conf'
    template = File.read location
    config   = ERB.new template
    put config.result(binding), '/etc/init.d/lamp.conf'
  end
end
