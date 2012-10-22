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
    # gem install capistrano-drupal
    
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
