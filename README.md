# Capdrupal

This gem provides a number of tasks which are useful for deploying & managing Drupal projects with [Capistrano](https://github.com/capistrano/capistrano).

# Capdrupal version

Capdrupal Gem Version | Branch | Capistrano Version | Drupal Version
--------------------- | ------ | ------------------ | --------------
7.x                   | d7     | 2                  | 7.x
8.x                   | d8     | 3.11               | 8.x

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capdrupal', '~>8.0' 
```

And then execute:

```shell
bundle
```

Or install it yourself if [gems](http://rubygems.org) is installed on your system:

```shell
gem install capdrupal
```

## Configuration

First, go to your project directory and launch Capistrano.

```shell
cd path/to/your/drupal/project/
cap install
```

Capistrano will create the following skeleton

```
.
├── Capfile
├── config
│   └── deploy.rb
│   └── deploy
│       └── production.rb
│       └── staging.rb
├── lib
│   └── capistrano
│        └── tasks

```

Create two files `Capfile` and `config/deploy.rb`. Open `Capfile` and set the dependencies.

```ruby
# Load DSL and set up stages.
require 'capistrano/setup'

# Include default deployment tasks.
require 'capistrano/deploy'

# Composer is needed to install drush on the server.
require 'capistrano/composer'

# Drupal Tasks.
require 'capdrupal/capistrano'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined.
Dir.glob('config/capistrano/tasks/*.rake').each { |r| import r }
```

Then, go to `config/deploy.rb` to set the parameters of your project. First you have to define the general information about the user, server and the app himself.

```ruby
set :application, 'application-name'
set :repo_url, 'git@github.com:company/application.git'

server 'ssh.example.org', user: 'username', roles: %w{app db web}
```

The specific Drupal information

```ruby
set :install_composer, true
set :install_drush, true

set :app_path, 'web'
set :config_path, 'config/sync'

# Setup the backup before/after failed strategy.
set :backup_path, 'backups'
set :keep_backups, 5

# Link file settings.php
set :linked_files, fetch(:linked_files, []).push("#{fetch(:app_path)}/sites/default/settings.php", "drush/drush.yml")

# Link dirs files and private-files
set :linked_dirs, fetch(:linked_dirs, []).push("#{fetch(:app_path)}/sites/default/files")
```

Then, all the others information related to your Git repository or debug level

```ruby
# Default value for :scm is :git
set :scm, :git

# Default value for :log_level is :debug
set :log_level, :debug
```

Finally, set the deployment to use the proper Drupal 8 strategy

```ruby
namespace :deploy do
  # Ensure everything is ready to deploy.
  after "deploy:check:directories", "drupal:db:backup:check"

  # Backup the database before starting a deployment and rollback on fail.
  # before :starting, "drupal:db:backup"
  # before :failed, "drupal:db:rollback"
   # before :cleanup, "drupal:db:backup:cleanup"

  # Set the maintenance Mode on your Drupal online project when deploying.
  after :updated, "drupal:maintenance:on"

  # Must updatedb before import configurations, E.g. when composer install new
  # version of Drupal and need updatedb scheme before importing new config.
  # This is executed without raise on error, because sometimes we need to do drush config-import before updatedb.
  after :updated, "drupal:updatedb:silence"

  # Remove the cache after the database update
  after :updated, "drupal:cache:clear"
  after :updated, "drupal:config:import"

  # Update the database after configurations has been imported.
  after :updated, "drupal:updatedb"

  # Clear your Drupal 8 cache.
  after :updated, "drupal:cache:clear"

  # Disable the maintence on the Drupal project.
  after :updated, "drupal:maintenance:off"

  # Ensure permissions are properly set.
  after :updated, "drupal:permissions:recommended"
  after :updated, "drupal:permissions:writable_shared"


  # Fix the release permissions (due to Drupal restrictive permissions)
  # before deletting old release.
  before :cleanup, :fix_permission do
    on roles(:app) do
      releases = capture(:ls, '-xtr', releases_path).split
      if releases.count >= fetch(:keep_releases)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories_str = directories.map do |release|
            releases_path.join(release)
          end.join(" ")
          execute :chmod, '-R' ,'ug+w', directories_str
        end
      end
    end
  end
end
```

You may now can configure your `staging.rb` and `production.rb` strategy, has you will certainly deploy on different environment

```shell
vi config/deploy/staging.rb
```

```ruby
# staging.example.org
set :deploy_to, '/home/example.org/www/staging.example.org'

# set a branch for this release
set :branch, 'dev'

# Map composer and drush commands
# NOTE: If stage have different deploy_to
# you have to copy those line for each <stage_name>.rb
# See https://github.com/capistrano/composer/issues/22
SSHKit.config.command_map[:composer] = shared_path.join("composer.phar")
SSHKit.config.command_map[:drush] = shared_path.join("vendor/bin/drush")
```

```shell
vi config/deploy/production.rb
```

```ruby
# www.example.org
set :deploy_to, '/home/example.org/www/example.org'

# set a branch for this release
set :branch, 'master'

# Map composer and drush commands
# NOTE: If stage have different deploy_to
# you have to copy those line for each <stage_name>.rb
# See https://github.com/capistrano/composer/issues/22
SSHKit.config.command_map[:composer] = shared_path.join("composer.phar")
SSHKit.config.command_map[:drush] = shared_path.join("vendor/bin/drush")
```

Awesome, your configuration is complete !

## Usage

So, after configuration come action ! The first time, you have to run this command with the choosing stage.

```shell
cap [staging|production] deploy:setup
```

In fact, Capistrano create directories and symlink to the targeted server. The `shared` directory contains all shared files of your app who don't need to be change. `Releases` contains the different releases of your app with a number define in `deploy.rb` and finally `current` is the symlink who target the right release.

```
example.org
├── current -> /home/example.org/releases/20130527070530
├── releases
│   ├── 20130527065508
│   ├── 20130527065907
│   └── 20130527070530
└── shared
```

Now, every time you want to deploy your app !

```
cap [staging|production] deploy
```

And if some troubles occur, just launch the rollback command to return to the previous release.

```
cap [staging|production] deploy:rollback
```

You should then be able to proceed as you would usually, you may want to familiarise yourself with the truncated list of tasks, you can get a full list with:

```
cap -T
```

## Credits

Inspired by [capistrano-drupal](https://github.com/previousnext/capistrano-drupal).

Made by [Antistatique](https://antistatique.net) who's always looking for new talented developers ! Just mail us on [job@antistatique.net](mailto:job@antistatique.net).
