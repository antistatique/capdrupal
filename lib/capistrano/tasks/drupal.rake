
# Load default values the capistrano 3.x way.
# See https://github.com/capistrano/capistrano/pull/605
namespace :load do
  task :defaults do
    set :composer_download_url, "https://getcomposer.org/installer"
  end
end


# Specific Drupal tasks
namespace :drupal do

  desc 'Run any drush command'
  task :drush do
    ask(:drush_command, "Drush command you want to run (eg. 'cache-rebuild'). Type 'help' to have a list of avaible command.")
    on roles(:app) do
      within fetch(:drupal_path) do
        execute :drush, fetch(:drush_command)
      end
    end
  end

  desc 'Show logs'
  task :logs do
    on roles(:app) do
      within fetch(:drupal_path) do
        execute :drush, 'watchdog-show  --tail'
      end
    end
  end

  desc 'Provides information about things that may be wrong in your Drupal installation, if any.'
  task :requirements do
    on roles(:app) do
      within fetch(:drupal_path) do
        execute :drush, 'core-requirements'
      end
    end
  end

  desc 'Open an interactive shell on a Drupal site.'
  task :cli do
    on roles(:app) do
      within fetch(:drupal_path) do
        execute :drush, 'core-cli'
      end
    end
  end

  namespace :config do
    desc 'List any pending database updates.'
    task :import do
      on roles(:app) do
        within fetch(:drupal_path) do
          execute :drush, 'config-import'
        end
      end
    end
  end

  namespace :update do
    desc 'List any pending database updates.'
    task :updatedb_status do
      on roles(:app) do
        within fetch(:drupal_path) do
          execute :drush, 'updatedb-status'
        end
      end
    end

    desc 'Apply any database updates required (as with running update.php).'
    task :updatedb do
      on roles(:app) do
        within fetch(:drupal_path) do
          execute :drush, 'updatedb'
        end
      end
    end

    desc 'Show a report of available minor updates to Drupal core and contrib projects.'
    task :updatedb_status do
      on roles(:app) do
        within fetch(:drupal_path) do
          execute :drush, 'pm-refresh'
          execute :drush, 'pm-updatestatus'
        end
      end
    end
  end

  namespace :cache do
    desc 'Clear all caches'
    task :clear do
      on roles(:app) do
        within fetch(:drupal_path) do
          execute :drush, 'cache-rebuild'
        end
      end
    end
  end

end

# Install composer
namespace :composer do
  desc "Install composer"
  task :install do
    on roles(:app) do
      within shared_path do
        execute 'curl', '-s' ,fetch(:composer_download_url) , '| php'
      end
    end
  end
end

# Install drush
namespace :drush do
  desc "Install Drush"
  task :install do
    on roles(:app) do
      within shared_path do
        execute :composer, 'require drush/drush:dev-master'
      end
    end
  end
end
