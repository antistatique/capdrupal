# Capistrano Drupal

This gem provides a number of tasks which are useful for deploying Drupal projects. 

Credit goes to railsless-deploy for many ideas here.

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

    $ gem install capistrano-drupal

### From Github

	$ git clone git://github.com/antistatique/capistrano-drupal.git
	$ cd capistrano-drupal
	$ gem build capistrano-drupal.gemspec
	$ gem install capistrano-drupal-{version}.gem

## Usage

Open your application's `Capfile` and make it begin like this:

    require 'rubygems'
    require 'railsless-deploy'
    require 'capistrano-drupal'
    load    'config/deploy'

You should then be able to proceed as you would usually, you may want to familiarise yourself with the truncated list of tasks, you can get a full list with:

    $ cap -T

## Roadmap

- Split out the tasks into indivual files/modules
- Use drush aliases
- Support install profiles
- Support composer
