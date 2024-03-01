namespace :load do
  task :defaults do
    set :app_path, 'web'
    set :config_path, 'config/sync'
    set :site_path, 'default'
    set :backup_path, 'backups'
    set :keep_backups, 5
    set :enable_modules, []
    set :disable_modules, []
    set :security, {
      # URL to be checked for security
      web_url: 'https://www.ovv.ch',
      audit_must_headers: [
        'x-xss-protection',
        'referrer-policy',
        'content-security-policy',
        'strict-transport-security',
      ],
      audit_must_not_headers: [
        'x-drupal-cache',
        'x-drupal-dynamic-cache',
        'x-generator',
      ],
      # Sensitive URLs from root (web_url) that should not be accessible.
      audit_must_not_url_fragments: [
       "core/install.php",
       "install.php",
       "update.php",
       "core/COPYRIGHT.txt",
       "core/CHANGELOG.txt",
       "core/INSTALL.mysql.txt",
       "core/INSTALL.pgsql.txt",
       "core/INSTALL.sqlite.txt",
       "core/MAINTAINERS.txt",
       "core/LICENSE.txt",
       "core/INSTALL.txt",
       "core/UPDATE.txt",
       "core/USAGE.txt",
       "CHANGELOG.txt",
       "INSTALL.txt",
       "example.gitignore",
      ],
      # Path of files to be removed from the release path.
      obscurity: [
       "#{fetch(:app_path)}/core/install.php",
       "#{fetch(:app_path)}/install.php",
       "#{fetch(:app_path)}/update.php",
       "#{fetch(:app_path)}/core/COPYRIGHT.txt",
       "#{fetch(:app_path)}/core/CHANGELOG.txt",
       "#{fetch(:app_path)}/core/INSTALL.mysql.txt",
       "#{fetch(:app_path)}/core/INSTALL.pgsql.txt",
       "#{fetch(:app_path)}/core/INSTALL.sqlite.txt",
       "#{fetch(:app_path)}/core/MAINTAINERS.txt",
       "#{fetch(:app_path)}/core/LICENSE.txt",
       "#{fetch(:app_path)}/core/INSTALL.txt",
       "#{fetch(:app_path)}/core/UPDATE.txt",
       "#{fetch(:app_path)}/core/USAGE.txt",
       "#{fetch(:app_path)}/CHANGELOG.txt",
       "#{fetch(:app_path)}/INSTALL.txt",
       "#{fetch(:app_path)}/example.gitignore",
     ]
    }
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
            next
          end

          # Revert from backup.
          execute :drush, 'sql:drop --yes'
          execute :drush, "sql:cli < #{backup}"

          # Delete the unziped backup.
          execute :rm, backup
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
  end

  namespace :cache do
    desc 'Clear all caches'
    task :clear do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'cr'
        end
      end
      Rake::Task['drupal:cache:clear'].reenable
    end
  end

  namespace :module do
    desc 'Enable module(s)'
    task :enable do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          for mod in fetch(:enable_modules)
            execute :drush, "en '#{mod}' -y"
          end
        end
      end
    end

    desc 'Disable module(s)'
    task :disable do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          for mod in fetch(:disable_modules)
            execute :drush, "pmu '#{mod}' -y"
          end
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
          execute :drush, 'cr', raise_on_non_zero_exit: false
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

  desc 'Update database with migrations scripts'
  task :updatedb do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, 'updatedb -y'
      end
    end
  end

  desc 'Run several commands after performing a code deployment (drush deploy)'
  task :deploy do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, 'deploy -y'
      end
    end
  end

  namespace :updatedb do
    desc 'Update database with migrations scripts'
    task :silence do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          execute :drush, 'updatedb -y', raise_on_non_zero_exit: false
        end
      end
    end
  end

  desc 'Apply pending entity schema updates'
  task :entup do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, 'entup -y'
      end
    end
  end

  namespace :config do
    desc 'Import configuration to active stage'
    task :import do
      on roles(:app) do
        try = 0
        full_config_path = release_path.join(fetch(:config_path))
        within release_path.join(fetch(:app_path)) do
          execute :drush, "config-import -y"
        rescue
          try += 1
          try < 5 ? retry : raise
        end
      end
    end
  end

  namespace :permissions do
    desc 'Set recommended Drupal permissions'
    task :recommended do
      on roles(:app) do
        within release_path.join(fetch(:app_path)) do
          # Remove execution for files, keep execution on folder.
          execute :find, './', '-type f ! -perm 444 -exec chmod 444 {} \;'
          execute :find, './', '-type d ! -perm 555 -exec chmod 555 {} \;'
        end
      end
    end

    desc 'Set cleanup permissions to allow deletion of releases'
    task :cleanup do
      on roles(:app) do
        releases = capture(:ls, '-x', releases_path).split
        valid, invalid = releases.partition { |e| /^\d{14}$/ =~ e }

        if valid.count >= fetch(:keep_releases)
          directories = (valid - valid.last(fetch(:keep_releases))).map do |release|
            releases_path.join(release)
          end
          if test("[ -d #{current_path} ]")
            current_release = capture(:readlink, current_path).to_s
            if directories.include?(current_release)
              directories.delete(current_release)
            end
          end
          if directories.any?
            directories.each_slice(100) do |directories_batch|
              execute :chmod, '-R' ,'ug+w', *directories_batch
            end
          end
        end
      end
    end

    desc 'Initalize shared path permissions'
    task :writable_shared do
      on roles(:app) do
        within shared_path do
          # Remove execution for files, keep execution on folder.
          # "web/sites/defaults/files" is a shared dir and should be writable.
          execute :find, "#{fetch(:app_path)}/sites/#{fetch(:site_path)}/files", '-type f ! -perm 664 -exec chmod 664 {} \;'
          execute :find, "#{fetch(:app_path)}/sites/#{fetch(:site_path)}/files", '-type d ! -perm 2775 -exec chmod 2775 {} \;'
        end
      end
    end
  end

  namespace :security do

  desc "Check Drupal recommended security layers"
    task :audit do
      run_locally do

        # Check for sensitives files.
        info "=================================="
        info "Ensure all obfuscated files are properly not accessible."
        fetch(:security)[:audit_must_not_url_fragments].each do |url_fragment|
          page_url = "#{fetch(:security)[:web_url]}/#{url_fragment}"

          info "Fetching #{page_url} ..."
          status_code = capture(:curl, '-LI', page_url, '-o /dev/null -w \'%{http_code}\n\' -s')
          if status_code == '200' then
            error "Page respond with status #{status_code}."
          else
            info "Page respond with status #{status_code}."
          end
        end

        # Check for debug Headers.
        info "=================================="
        info "Ensure sensitive or debug Headers are disabled."
        fetch(:security)[:audit_must_not_headers].each do |header|
          header_value = capture(:curl, '-LI', fetch(:security)[:web_url], "-o /dev/null -w '%header{#{header}}' -s")

          if header_value == '' then
            error "Header #{header} contains value #{header_value}."
          end
        end

        # Check for security Headers.
        info "=================================="
        info "Ensure security Headers are enabled."
        fetch(:security)[:audit_must_headers].each do |header|
          header_value = capture(:curl, '-LI', fetch(:security)[:web_url], "-o /dev/null -w '%header{#{header}}' -s")

          if header_value == '' then
            error "Header #{header} should be configured."
          else
            info "Header #{header} is configured with #{header_value}."
          end
        end
      end
    end

    desc 'Security by Obscurity'
    namespace :obscurity do

      desc 'Obfuscate Drupal sensitive files by deletion'
      task :files do
        on roles(:app) do
          within release_path do
            fetch(:security)[:obscurity].each do |file|
              execute :rm, file, '-f'
            end
          end
        end
      end

      desc 'Obfuscate Drupal sensitive files by htaccess'
      task :htaccess do
        on roles(:app) do
          htaccessFile = release_path.join(fetch(:app_path)).join('.htaccess')

          [
            '## added during deploy',
            '## Obfuscate Drupal sensitive files by denying access',
            '<FilesMatch "(^API|CHANGELOG|COPYRIGHT|INSTALL|LICENSE|PATCHES|MAINTAINERS|README|TODO|UPGRADE|UPDATE|CHANGES|install|update|authorize).*\.(md|txt|php)$">',
            '  Order deny,allow',
            '  Deny from all',
            '</FilesMatch>'
          ].each { |line| execute "echo '#{line}' >> #{htaccessFile}" }
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
            remote_files_dir = "#{shared_path}/#{(fetch(:app_path))}/sites/#{fetch(:site_path)}/files/"
            local_files_dir = "#{(fetch(:app_path))}/sites/#{fetch(:site_path)}/files/"
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
          remote_files_dir = "#{shared_path}/#{(fetch(:app_path))}/sites/#{fetch(:site_path)}/files/"
          local_files_dir = "#{(fetch(:app_path))}/sites/#{fetch(:site_path)}/files/"
          system("rsync --recursive --times --rsh=ssh --human-readable --progress --exclude='.*' --exclude='css' --exclude='js' #{local_files_dir} #{server.user}@#{server.hostname}:#{remote_files_dir}")
        end
      end
    end
  end
end
