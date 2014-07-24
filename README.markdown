# Capdrupal

This gem provides a number of tasks which are useful for deploying Drupal projects with [Capistrano](https://github.com/capistrano/capistrano). 

# Capdrupal Version


Capdrupal Gem Version | Branch | Capistrano Version | Drupal Version 
--------------------- | ------ | ------------------ | --------------
0.x                   |  d7    |   2                |    7.x
2.x                   | master |   3                |    8.x


## Installation
[gems](http://rubygems.org) must be installed on your system first.

### From RubyGems.org 

    $ gem install capdrupal

### From Github

	$ git clone git://github.com/antistatique/capdrupal.git
	$ cd capdrupal
	$ gem build capdrupal.gemspec
	$ gem install capdrupal-{version}.gem
	
### Install with Bundler (recomanded)

This version use capistrano 3. Installation with [bundler](http://bundler.io/) let you use both version and avoid conflict.

Create a 'Gemfile' on the root of your project


	group :development do
	  gem 'capdrupal', '~> 2.0.0'
	end
	
Install the depencies

	$ bundle install
	
Use capistrano throuw bundle

	$ bundle exec cap deploy

	
## Configuration

It's highly recommended to use Git in your project, but you can also use Subversion or your favorite versionning software. This tutorial his made for multistage deployment, but you can easily use it just for one target. 

First, go to your project directory and launch Capistrano.

	$ cd path/to/your/directory/
	$ capify .
	
Capistrano create two files `capfile` and `config/deploy.rb`. Open `capfile` and set the depencies.

	require 'rubygems'
	require 'capdrupal'
	load    'config/deploy'
	
Then, go to `config/deploy.rb` to set the parameters of your project. First you have to define the general informations about the user, server and the app himself.

	# USER
	set :user,            "name"
	set :group,           "name"
	set :runner_group,    "name"
	
	# APP
	set :application,     "appName"
	
	# The domain and the path to your app directory
	set :domain,    "staging.domain.com"
	set :deploy_to, "/home/path/to/my/app/"

Drupal shared path

	# DRUPAL
	set :linked_files, %w{sites/default/settings.php}
        # Default value for linked_dirs is []
        set :linked_dirs, %w{sites/default/files}

Then, all the informations related to your Git repository

	set :repo_url,     "git@github.com:user/repo-name.git"
	set :branch,         "dev"


## Usage

So, after configuration come action ! The first time, you have to run this command with the choosing stage.

	$ cap deploy:setup
	
In fact, Capistrano create directories and symlink to the targeted server. The `shared` directory contains all shared files of your app who don't need to be change. `Releases` contains the different releases of your app with a number define in `deploy.rb` and finally `current` is the symlink who target the right release.

	myApp
	├── current -> /home/myApp/releases/20130527070530
	├── releases
	│   ├── 20130527065508
	│   ├── 20130527065907
	│   └── 20130527070530
	└── shared

Now, every time you want to deploy you app !

	$ cap deploy
	
And if some troubles occur, juste launch the rollback command to return to the previous release.

	$ cap deploy:rollback


You should then be able to proceed as you would usually, you may want to familiarise yourself with the truncated list of tasks, you can get a full list with:

    $ cap -T
    
This show a list of all avaible commands:

    
cap composer:install               # Install composer
cap deploy                         # Deploy a new release
cap deploy:check                   # Check required files and directories exist
cap deploy:check:directories       # Check shared and release directories exist
cap deploy:check:linked_dirs       # Check directories to be linked exist in shared
cap deploy:check:linked_files      # Check files to be linked exist in shared
cap deploy:check:make_linked_dirs  # Check directories of files to be linked exist in shared
cap deploy:cleanup                 # Clean up old releases
cap deploy:cleanup_rollback        # Remove and archive rolled-back release
cap deploy:finished                # Finished
cap deploy:finishing               # Finish the deployment, clean up server(s)
cap deploy:finishing_rollback      # Finish the rollback, clean up server(s)
cap deploy:log_revision            # Log details of the deploy
cap deploy:published               # Published
cap deploy:publishing              # Publish the release
cap deploy:revert_release          # Revert to previous release timestamp
cap deploy:reverted                # Reverted
cap deploy:reverting               # Revert server(s) to previous release
cap deploy:rollback                # Rollback to previous release
cap deploy:set_current_revision    # Place a REVISION file with the current revision SHA in the current release path
cap deploy:started                 # Started
cap deploy:starting                # Start a deployment, make sure server(s) ready
cap deploy:symlink:linked_dirs     # Symlink linked directories
cap deploy:symlink:linked_files    # Symlink linked files
cap deploy:symlink:release         # Symlink release to current
cap deploy:symlink:shared          # Symlink files and directories from shared to release
cap deploy:updated                 # Updated
cap deploy:updating                # Update server(s) by setting up a new release
cap drupal:cache:clear             # Clear all caches
cap drupal:cli                     # Open an interactive shell on a Drupal site
cap drupal:config:import           # List any pending database updates
cap drupal:drush                   # Run any drush command
cap drupal:logs                    # Show logs
cap drupal:requirements            # Provides information about things that may be wrong in your Drupal installation, if any
cap drupal:update:updatedb         # Apply any database updates required (as with running update.php)
cap drupal:update:updatedb_status  # List any pending database updates / Show a report of available minor updates to Drupal core and contrib projects
cap drush:install                  # Install Drush
cap install                        # Install Capistrano, cap install STAGES=staging,production


## Credits

Inspired by [capistrano-drupal](https://github.com/previousnext/capistrano-drupal).

Made by [Antistatique](http://www.antistatique.net) who's always looking for new talented developpers ! Just mail us on [job@antistatique.net](mailto:hello@antistatique.net).
