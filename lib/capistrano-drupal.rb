Capistrano::Configuration.instance(:must_exist).load do

  require 'capistrano/recipes/deploy/scm'
  require 'capistrano/recipes/deploy/strategy'
  
  # =========================================================================
  # These variables may be set in the client capfile if their default values
  # are not sufficient.
  # =========================================================================

  _cset :scm, :git
  _cset :deploy_via, :remote_cache
  _cset :branch, "master"
  _cset :git_enable_submodules, true
  
  _cset :drush_cmd, "drush"
  
  _cset :runner_group, "www-data"
  _cset :group_writable, false
  
  _cset(:deploy_to) { "/var/www/#{application}" }
  _cset(:app_path) { "drupal" }
  _cset :shared_children, false
  
  after "deploy:update_code", "drupal:symlink_shared", "drush:site_offline", "drush:updatedb", "drush:cache_clear", "drush:feature_revert", "drush:site_online"

  # This is an optional step that can be defined.
  #after "deploy", "git:push_deploy_tag"
  
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
      dirs = [deploy_to, releases_path, shared_path].join(' ')
      run "#{try_sudo} mkdir -p #{releases_path} #{shared_path}"
      run "#{try_sudo} chown -R #{user}:#{runner_group} #{deploy_to}"
      if shared_children.size > 0
        sub_dirs = shared_children.map { |d| File.join(shared_path, d) }
        run "#{try_sudo} mkdir -p #{sub_dirs.join(' ')}"
        run "#{try_sudo} chmod 2775 #{sub_dirs.join(' ')}"
      end
    end
  end
  
  namespace :drupal do
    desc "Symlinks static directories and static files that need to remain between deployments"
    task :symlink_shared, :roles => :app, :except => { :no_release => true } do
      if shared_children
        # Creating symlinks for shared directories
        shared_children.each do |link|
          run "#{try_sudo} mkdir -p #{shared_path}/#{link}"
          run "#{try_sudo} sh -c 'if [ -d #{release_path}/#{link} ] ; then rm -rf #{release_path}/#{link}; fi'"
          run "#{try_sudo} ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
        end
      end

      if shared_files
        # Creating symlinks for shared files
        shared_files.each do |link|
          link_dir = File.dirname("#{shared_path}/#{link}")
          run "#{try_sudo} mkdir -p #{link_dir}"
          run "#{try_sudo} touch #{shared_path}/#{link}"
          run "#{try_sudo} ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
        end
      end
    end
  end
  
  namespace :git do

    desc "Place release tag into Git and push it to origin server."
    task :push_deploy_tag do
      user = `git config --get user.name`
      email = `git config --get user.email`
      tag = "release_#{release_name}"
      if exists?(:stage)
        tag = "#{stage}_#{tag}"
      end
      puts `git tag #{tag} #{revision} -m "Deployed by #{user} <#{email}>"`
      puts `git push origin tag #{tag}`
    end

   end
  
  namespace :drush do

    desc "Set the site offline"
    task :site_offline, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset site_offline 1 -y"
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset maintenance_mode 1 -y"
    end

    desc "Backup the database"
    task :backupdb, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} bam-backup"
    end

    desc "Run Drupal database migrations if required"
    task :updatedb, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} updatedb -y"
    end

    desc "Clear the drupal cache"
    task :cache_clear, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} cc all"
    end

    desc "Revert feature"
    task :feature_revert, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} fr all"
    end

    desc "Set the site online"
    task :site_online, :on_error => :continue do
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset site_offline 0 -y"
      run "#{drush_cmd} -r #{latest_release}/#{app_path} vset maintenance_mode 0 -y"
    end

  end
  
end