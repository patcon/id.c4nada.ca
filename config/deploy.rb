#################
# GLOBAL CONFIG
#################
set :application, 'idp'
set :assets_roles, [:app, :web]
# set branch based on env var or ask with the default set to the current local branch
set :branch, ENV['branch'] || ENV['BRANCH'] || ask(:branch, `git branch`.match(/\* (\S+)\s/m)[1])
set :bundle_without, 'deploy development doc test'
set :deploy_to, '/srv/idp'
set :deploy_via, :remote_cache
set :keep_releases, 5
set :linked_files, %w(certs/saml.crt
                      config/application.yml
                      config/database.yml
                      config/newrelic.yml
                      keys/saml.key.enc)
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)
set :passenger_roles, [:web]
set :passenger_restart_wait, 5
set :passenger_restart_runner, :sequence
set :rails_env, :production
set :repo_url, 'https://github.com/18F/identity-idp.git'
set :sidekiq_options, ''
set :sidekiq_queue, [:analytics, :mailers, :sms, :voice]
set :sidekiq_monit_use_sudo, true
set :sidekiq_user, 'ubuntu'
set :ssh_options, forward_agent: false, user: 'ubuntu'
set :whenever_roles, [:job_creator]
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

#########
# TASKS
#########
# rubocop:disable Metrics/BlockLength
namespace :deploy do
  desc 'Install npm packages required for asset compilation with browserify'
  task :browserify do
    on roles(:app, :web), in: :sequence do
      within release_path do
        execute :npm, 'install'
      end
    end
  end

  desc 'Write deploy information to deploy.json'
  task :deploy_json do
    on roles(:app, :web), in: :parallel do
      require 'stringio'

      within current_path do
        deploy = {
          env: fetch(:stage),
          branch: fetch(:branch),
          user: fetch(:local_user),
          sha: fetch(:current_revision),
          timestamp: fetch(:release_timestamp)
        }

        execute :mkdir, '-p', 'public/api'

        # the #upload! method does not honor the values of #within at the moment
        # https://github.com/capistrano/sshkit/blob/master/EXAMPLES.md#upload-a-file-from-a-stream
        upload! StringIO.new(deploy.to_json), "#{current_path}/public/api/deploy.json"

        execute :chmod, '+r', 'public/api/deploy.json'
      end
    end
  end

  before 'assets:precompile', :browserify
  after 'deploy:updated', 'newrelic:notice_deployment'
  after 'deploy:log_revision', :deploy_json
end
# rubocop:enable Metrics/BlockLength
