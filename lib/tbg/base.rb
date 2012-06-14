require 'capistrano/tbg/common'

unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano/tbg/deploy requires Capistrano 2"
end

Capistrano::Configuration.instance.load do
  # User details
  _cset :user,          'deploy'
  _cset(:group)         { user }
  
  # Application details
  _cset(:app_name)      { abort "Please specify the short name of your application, set :app_name, 'foo'" }
  _cset(:application)     { app_name }
  _cset(:runner)        { user }
  _cset :use_sudo,      false

  # SCM settings
  _cset(:app_dir)        { "/home/#{user}/deployments/#{application}" }
  _cset :scm,           'git'
  _cset(:repository)      { "git@github.com:thebeansgroup/#{app_name}.git" }
  _cset :branch,        'master'
  _cset :deploy_via,    'remote_cache'
  _cset(:deploy_to)       { app_dir }

  # Git settings for Capistrano
  default_run_options[:pty]     = true # needed for git password prompts
  ssh_options[:forward_agent]   = true # use the keys for the person running the cap command to check out the append
  ssh_options[:auth_methods] = ["publickey"]
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", user)]
  
  namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
  end
  
end