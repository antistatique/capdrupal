# Capdrupal

This gem provides a number of tasks which are useful for deploying Drupal projects with capistrano. 

Credit goes to https://github.com/previousnext/capistrano-drupal for many ideas here.

## Installation
These gems must be installed on your system first.

* capistrano
* rubygems
* railsless-deploy

You can check to see a list of installed gems by running this.

    $ gem query --local

If any of these gems is missing you can install them with:

    $ gem install gemname

Finally install the capistrano-drupal recipes as a gem.

### From RubyGems.org

    $ gem install capdrupal

### From Github

	$ git clone git://github.com/antistatique/capdrupal.git
	$ cd capdrupal
	$ gem build capdrupal.gemspec
	$ gem install capdrupal-{version}.gem

## Usage

Open your application's `Capfile` and make it begin like this:

    require 'rubygems'
    require 'railsless-deploy'
    require 'capistrano-drupal'
    load    'config/deploy'

You should then be able to proceed as you would usually, you may want to familiarise yourself with the truncated list of tasks, you can get a full list with:

    $ cap -T
    
This show a list of all avaible commands:
    
	cap deploy                # Deploys your project.
	cap deploy:check          # Test deployment dependencies.
	cap deploy:cleanup        # Clean up old releases.
	cap deploy:cold           # Deploys and starts a `cold' application.
	cap deploy:create_symlink # Updates the symlink to the most recently deployed version.
	cap deploy:pending        # Displays the commits since your last deploy.
	cap deploy:pending:diff   # Displays the `diff' since your last deploy.
	cap deploy:rollback       # Rolls back to a previous version and restarts.
	cap deploy:rollback:code  # Rolls back to the previously deployed version.
	cap deploy:setup          # Prepares one or more servers for deployment.
	cap deploy:symlink        # Deprecated.
	cap deploy:update         # Copies your project and updates the symlink.
	cap deploy:update_code    # Copies your project to the remote servers.
	cap deploy:upload         # Copy files to the currently deployed version.
	cap dev                   # Set the target stage to `dev'.
	cap drupal:symlink_shared # Symlinks static directories and static files that need to remain between d...
	cap drush:backupdb        # Backup the database
	cap drush:cache_clear     # Clear the drupal cache
	cap drush:feature_revert  # Revert feature
	cap drush:get             # Gets drush and installs it
	cap drush:site_offline    # Set the site offline
	cap drush:site_online     # Set the site online
	cap drush:updatedb        # Run Drupal database migrations if required
	cap files:pull            # Pull drupal sites files (from remote to local)
	cap files:push            # Push drupal sites files (from local to remote)
	cap git:push_deploy_tag   # Place release tag into Git and push it to origin server.
	cap invoke                # Invoke a single command on the remote servers.
	cap multistage:prepare    # Stub out the staging config files.
	cap prod                  # Set the target stage to `prod'.
	cap shell                 # Begin an interactive Capistrano session.

