Capistrano::Configuration.instance(:must_exist).load do

  require 'capistrano/recipes/deploy/scm'
  require 'capistrano/recipes/deploy/strategy'
  
  # =========================================================================
  # These variables may be set in the client capfile if their default values
  # are not sufficient.
  # =========================================================================

  set :scm, :git
  set :deploy_via, :remote_cache
  _cset :branch, "master"
  _cset :git_enable_submodules, true
  _cset :runner_group, "www-data"

  _cset(:deploy_to) { "/var/www/#{application}" }
  _cset :shared_children, ['files']
  
  _cset(:db_root_password) {
    Capistrano::CLI.ui.ask("MySQL root password:")
  }
  
  _cset(:db_username) {
    Capistrano::CLI.ui.ask("MySQL username:")
  }
  
  _cset(:db_password) {
    Capistrano::CLI.ui.ask("MySQL password:")
  }
  
  after :symlink, "drupal:symlink_shared"
  after "deploy:setup", "deploy:set_permissions"
  after "deploy:setup", "drush:createdb"
  after "deploy:setup", "drush:init_settings"
  before "drush:updatedb", "drush:backupdb"
  after "deploy:update_code", "drush:updatedb"
  after "deploy:finalize_update", "drush:cache_clear"
  after "deploy:finalize_update", "git:push_deploy_tag"
  after "deploy:cleanup", "git:cleanup_deploy_tag"
  
  namespace :deploy do
    desc <<-DESC
      Prepares one or more servers for deployment. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:

        $ cap HOSTS=new.server.com deploy:setup

      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
    task :setup, :except => { :no_release => true } do
      dirs = [deploy_to, releases_path, shared_path]
      dirs += shared_children.map { |d| File.join(shared_path, d) }
      run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chown #{runner}:#{runner_group} #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    end
  end
  
  namespace :drupal do
    desc "Symlink settings and files to shared directory. This allows the settings.php and \
      and sites/default/files directory to be correctly linked to the shared directory on a new deployment."
    task :symlink_shared do
      ["files", "settings.php"].each do |asset|
        run "rm -rf #{app_path}/#{asset} && ln -nfs #{shared_path}/#{asset} #{app_path}/sites/default/#{asset}"
      end
    end
  end
  
  namespace :git do

    desc "Place release tag into Git and push it to origin server."
    task :push_deploy_tag do
      user = `git config --get user.name`
      email = `git config --get user.email`

      puts `git tag release_#{release_name} #{revision} -m "Deployed by #{user} <#{email}>"`
      puts `git push --tags`
    end

    desc "Place release tag into Git and push it to server."
    task :cleanup_deploy_tag do
      count = fetch(:keep_releases, 5).to_i
      if count >= releases.length
        logger.important "no old release tags to clean up"
      else
        logger.info "keeping #{count} of #{releases.length} release tags"

        tags = (releases - releases.last(count)).map { |release| "release_#{release}" }

        tags.each do |tag|
          `git tag -d #{tag}`
          `git push origin :refs/tags/#{tag}`
        end
      end
    end
  end
  
  namespace :drush do

    desc "Backup the database"
    task :backupdb, :on_error => :continue do
      t = Time.now.utc.strftime("%Y-%m-%dT%H-%M-%S")
      run "drush -r #{current_path}/pressflow sql-dump --result-file=/tmp/#{application}-#{t}.sql"
    end

    desc "Run Drupal database migrations if required"
    task :updatedb, :on_error => :continue do
      run "drush -r #{app_path} updatedb -y"
    end

    desc "Clear the drupal cache"
    task :cache_clear, :on_error => :continue do
      run "drush -r #{app_path}  cc all"
    end

    desc "Create the database"
    task :createdb, :on_error => :continue do
      run "mysqladmin -uroot -p#{db_root_password} create #{app_name}"
      run "mysql -uroot -p#{db_root_password} #{app_name} -e \"grant all on #{app_name}.* to '#{db_username}'@'localhost' identified by '#{db_password}'\""    
    end

    desc "Initialise settings.php"
    task :init_settings do
      upload "pressflow/sites/default/default.settings.php", "#{shared_path}/settings.php"
      run "chmod 664 #{shared_path}/settings.php"
    end

  end
  
end