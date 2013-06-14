# Capdrupal

This gem provides a number of tasks which are useful for deploying Drupal projects with [Capistrano](https://github.com/capistrano/capistrano). 


## Installation

### Vendors
Your Ruby version must be highter than 1.3.0 and these [gems](http://rubygems.org) must be installed on your system first.

* capistrano
* railsless-deploy

One by one

	$ gem install capistrano
	$ gem install railsless-deploy
	
If you don't know if it's already install, check the list of your installed gems.

    $ gem query --local

Finally install the capistrano-drupal recipes as a gem or manually from Github.

### From RubyGems.org

    $ gem install capdrupal

### From Github

	$ git clone git://github.com/antistatique/capdrupal.git
	$ cd capdrupal
	$ gem build capdrupal.gemspec
	$ gem install capdrupal-{version}.gem

	
## Configuration

It's highly recommended to use Git in your project, but you can also use Subversion or your favorite versionning software. This tutorial his made for multistage deployment, but you can easily use it just for one target. 

First, go to your project directory and launch Capistrano.

	$ cd path/to/your/directory/
	$ capify .
	
Capistrano create two files `capfile` and `config/deploy.rb`. Open `capfile` and set the depencies.

	require 'rubygems'
	require 'railsless-deploy'
	require 'capistrano-drupal'
	load    'config/deploy'
	
Then, go to `config/deploy.rb` to set the parameters of your project. First you have to define the general informations (generaly use by multiple server) and the different stage you have.

	# USER
	set :user,            "name"
	set :group,           "name"
	set :runner_group,    "name"
	
	# APP
	set :application,     "appName"
	set :stages,          %w(stage1 stage2)

The specific Drupal informations and if you have already or not [Drush](https://drupal.org/project/drush) installed on your server (if your not sure, keep it TRUE).

	# DRUPAL
	set :app_path,        "drupal"
	set :shared_children, ['drupal/sites/default/files']
	set :shared_files,    ['drupal/sites/default/settings.php'] 
	set :download_drush,  true

Then, all the informations related to your Git repository

	set :scm,            "git"
	set :repository,     "git@github.com:user/repo-name.git"
	
Finally, set the other Capistrano related options, the number of realeases you want and the cleanup at the end of the deployment.

	set :use_sudo,       false
	default_run_options[:pty] = true
	ssh_options[:forward_agent] = true	
	role :app,           domain
	role :db,            domain
	
	set  :keep_releases,   5
	after "deploy:update", "deploy:cleanup" 
	
Awesome, your configuration file is almost complete ! From now and whenever you want to add a new stage, create an new file in `config/deploy/` with in :

	# Stage name (same as your filename, for example stage1.rb)
	set :stages,    "stage1"

	# The Git branch you want to use
	set :branch,    "dev"
	
	# The domain and the path to your app directory
	set :domain,    "staging.domain.com"
	set :deploy_to, "/home/path/to/my/app/"

	# And the user if it's not the same as define in deploy.rb
	set :user,           "staging"
	set :group,          "staging"
	set :runner_group,   "staging"

## Usage

So, after configuration come action ! The first time, you have to run this command with the choosing stage.

	$ cap stage1 deploy:setup
	
In fact, Capistrano create directories and symlink to the targeted server. The `shared` directory contains all shared files of your app who don't need to be change. `Releases` contains the different releases of your app with a number define in `deploy.rb` and finally `current` is the symlink who target the right release.

	myApp
	├── current -> /home/myApp/releases/20130527070530
	├── releases
	│   ├── 20130527065508
	│   ├── 20130527065907
	│   └── 20130527070530
	└── shared

Now, every time you want to deploy you app !

	$ cap stage1 deploy
	
And if some troubles occur, juste launch the rollback command to return to the previous release.

	$ cap deploy:rollback


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


## Credits

Inspired by [capistrano-drupal](https://github.com/previousnext/capistrano-drupal).

Made by [Antistatique](http://www.antistatique.net) who's always looking for new talented developpers ! Just mail us on [hello@antistatique.net](mailto:hello@antistatique.net).
