namespace :load do
  task :defaults do
    set :install_composer, true
    set :install_drush, true
    set :app_path, 'web'
    set :config_name, 'sync'
    set :backup_path, 'backups'
    set :keep_backups, 5

    default = YAML.load_file('./config/d8/sync/system.site.yml')

    ask(:drupal_uuid, default['uuid'])
    ask(:drupal_site_name, default['name'])
    ask(:drupal_admin_username, 'admin')
    ask(:drupal_admin_passowrd, 'admin', echo: false)
    ask(:drupal_admin_email, default['mail'])
  end
end

namespace :drush do
  desc "Install Drush - only once for bootstraping"
  task :install do
    on roles(:app) do
      within shared_path do
        execute :composer, 'require drush/drush'
      end
    end
  end
end

namespace :drupal do

  desc 'Bootstrap Drupal site with drush site-install command'
  task :bootstrap do
    ask(:site_name, "Site name")

    warn <<-EOF

    ************************** WARNING ****************************
    If you type [yes], cap drupal:bootstrap will WIPE your database
    any other input will cancel the operation.
    ***************************************************************

    EOF
    ask :answer, 'Are you sure you want to WIPE your database?: '

    if fetch(:answer) == 'yes'
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'si standard -y',
            %(--site-name="#{fetch(:drupal_site_name)}"),
            %(--account-name="#{fetch(:drupal_admin_username)}"),
            %(--account-pass="#{fetch(:drupal_admin_passowrd)}"),
            %(--account-mail="#{fetch(:drupal_admin_email)}")
          execute :drush, %(config-set system.site uuid "#{fetch(:drupal_uuid)}" -y)
        end
      end
    else
      exit
    end
  end

  desc 'Run any drush command'
  task :drush do
    ask(:drush_command, "Drush command you want to run (eg. 'cache-clear css-js'). Type 'help' to have a list of avaible drush commands.")
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, fetch(:drush_command)
      end
    end
  end

  namespace :db do
    desc "Revert the current release drupal site database backup"
    task :rollback do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          backup = "#{shared_path}/#{fetch(:backup_path)}/#{fetch(:stage)}_#{release_timestamp}"

          # Unzip the file for rollback.
          execute "gunzip #{backup}.gz"

          unless test "[ -f #{backup} ]"
            warn "backup file #{backup} does not exist."
            next ""
          end

          # Revert from backup.
          execute :drush, "sql:cli < #{backup}"

          # Delete the unziped backup.
          execute :rm, "#{backup}"
        end
      end
    end

    desc "Backup drupal site database"
    task :backup do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          backup_destination = "#{shared_path}/#{fetch(:backup_path)}/#{fetch(:stage)}_#{release_timestamp}"
          execute :drush, "sql:dump --result-file=#{backup_destination} --gzip"
        end
      end
    end

    namespace :backup do
      desc "Check required files and directories exist"
      task :check do
        on release_roles :all do
          execute :mkdir, "-p", "#{shared_path}/#{fetch(:backup_path)}"
        end
      end

      desc "Clean up old drupal site database backup"
      task :cleanup do
        on roles(:app) do
          within release_path.join(fetch(:app_path)) do
            backup_path = "#{shared_path}/#{fetch(:backup_path)}"
            keep_backups = fetch(:keep_backups, 5)

            # Fetch every file from the backup directory, oldest on top.
            backups = capture(:ls, "-ltrx", backup_path).split
            info "Keeping #{keep_backups} of #{backups.count} backup dump on #{backup_path}."

            # If we found less file than the keep number finish the task here
            next "" unless backups.count > keep_backups.to_i

            # Calculate number of file to delete.
            to_delete = backups.count - keep_backups.to_i

            # Loop throught file to delete (oldest files on top).
            backups[0, to_delete].map do |backup|
              execute :rm, "#{backup_path}/#{backup}"
            end
          end
        end
      end
    end

    desc 'Update database with migrations scripts (stop on fail)'
    task :update do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'updatedb -y'
        end
      end
    end

    namespace :update do
      desc 'Update database with migrations scripts (continue on fail)'
      task :silence do
        on roles(:app) do
          within release_path.join(fetch(:app_path)) do
            execute :drush, 'updatedb -y', raise_on_non_zero_exit: false
          end
        end
      end
    end
  end

  namespace :cache do
    desc 'Clear all caches'
    task :clear do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'cr'
        end
      end
    end
  end

  namespace :maintenance do
    desc "Set maintenance mode"
    task :on do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, "state:set system.maintenance_mode 1 -y"
          execute :drush, 'cr'
        end
      end
    end

    desc "Remove maintenance mode"
    task :off do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, "state:set system.maintenance_mode 0 -y"
          execute :drush, 'cr'
        end
      end
    end
  end

  namespace :entity do
    desc 'Apply pending entity schema updates'
    task :update do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'entup -y'
        end
      end
    end
  end

  namespace :config do
    desc 'Import configuration to active stage'
    task :import do
      on roles(:app) do
        try = 0
        config_path = release_path.join('config').join('d8').join(fetch(:config_name))
        within release_path.join(fetch(:app_path)) do
          execute :drush, "config-import -y --source=#{config_path}"
        rescue
          try += 1
          try < 5 ? retry : raise
        end
      end
    end

    desc 'Show proposed changes *before* importing configuration to the active stage'
    task :import_preview do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'config-import --preview=list'
        end
      end
    end
  end

  namespace :permissions do
    desc 'Set recommended Drupal permissions'
    task :recommended do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :chmod, '-R', '555', '.'

          # Remove execution for files, keep execution on folder.
          execute 'find', './ -type f -executable -exec chmod -x {} \;'
          execute 'find', './ -type d -exec chmod +x {} \;'
        end
      end
    end

    desc 'Initalize shared path permissions'
    task :shared do
      on roles(:app) do
        within shared_path do
          execute :chmod, '-R', '775', './web/sites/default/files'

          # Remove execution for files, keep execution on folder.
          execute 'find', './web/sites/default/files -type f -executable -exec chmod -x {} \;'
          execute 'find', './web/sites/default/files -type d -exec chmod +xs {} \;'
        end
      end
    end
  end
end

namespace :files do
  desc "Download drupal sites files (from remote to local)"
  task :download do
    run_locally do
      on release_roles :app do |server|
        ask(:answer, "Do you really want to download the files on the server to your local files? Nothings will be deleted but files can be ovewrite. (y/N)");
        if fetch(:answer) == 'y' then
          remote_files_dir = "#{shared_path}/#{(fetch(:app_path))}/sites/default/files/"
          local_files_dir = "#{(fetch(:app_path))}/sites/default/files/"
          system("rsync --recursive --times --rsh=ssh --human-readable --progress --exclude='.*' --exclude='css' --exclude='js' #{server.user}@#{server.hostname}:#{remote_files_dir} #{local_files_dir}")
        end
      end
    end
  end

  desc "Upload drupal sites files (from local to remote)"
  task :upload do
    on release_roles :app do |server|
      ask(:answer, "Do you really want to upload your local files to the server? Nothings will be deleted but files can be ovewrite. (y/N)");
      if fetch(:answer) == 'y' then
        remote_files_dir = "#{shared_path}/#{(fetch(:app_path))}/sites/default/files/"
        local_files_dir = "#{(fetch(:app_path))}/sites/default/files/"
        system("rsync --recursive --times --rsh=ssh --human-readable --progress --exclude='.*' --exclude='css' --exclude='js' #{local_files_dir} #{server.user}@#{server.hostname}:#{remote_files_dir}")
      end
    end
  end
end
