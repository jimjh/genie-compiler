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

set :app_port, 3300

role :app, 'beta.geniehub.org'

after 'deploy:restart', 'deploy:cleanup'
after 'deploy:setup',   'deploy:upstart'

def with_user(user)
  old_user = user
  set :user, user
  close_sessions
  yield
  set :user, old_user
  close_sessions
end

def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

# Same as +put+, but use sudo to move the file to a privileged directory.
# @option [String] opts :sudoer      name of user with sudo privileges
def sudo_put(data, path, opts = {})
  sudoer = opts.delete(:sudoer) || user
  filename = File.basename path
  dirname  = File.dirname  path
  temp     = "#{shared_path}/#{filename}"
  put data, temp, opts
  with_user sudoer do
    run "#{sudo} mv #{temp} #{dirname}"
  end
end

namespace :deploy do

  task :start do
    with_user('codex') { run 'sudo service lamp start' }
  end

  task :stop do
    with_user('codex') { run 'sudo service lamp stop' }
  end

  task :restart do
    with_user('codex') { run 'sudo service lamp restart' }
  end

  task :upstart do
    location = fetch(:template_dir, 'config') + '/lamp.conf'
    template = File.read location
    config   = ERB.new template
    sudo_put config.result(binding), '/etc/init/lamp.conf', sudoer: 'codex'
  end

end
