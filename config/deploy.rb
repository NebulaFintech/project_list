# frozen_string_literal: true

# Github Config
set :repo_url, 'https://nebulafintechmu:mU7U4K5aAtVueXqj@github.com/NebulaFintech/project_list.git'
set :branch, :master

# User Config
set :user,            'ec2-user'
set :use_sudo,        false

# Deploy Config
set :application,     'project_list'
set :deploy_via,      :remote_cache
set :deploy_to,       "/#{fetch(:application)}"
set :keep_releases, 3

# Application Config
set :puma_conf,       "#{shared_path}/config/puma.rb"

# Logging Config
set :format,        :pretty
set :log_level,     :info

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
      execute "mkdir #{shared_path}/environments -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts 'WARNING: HEAD is not the same as origin/master'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  before :starting,        :check_revision
  after  :finishing,       :compile_assets
  after  :finishing,       :cleanup
end
