# Capistrano Drupal

This gem provides a number of tasks which are useful for deploying Drupal projects. 

Credit goes to railsless-deploy for many ideas here.

## Installation

    # gem install capistrano-drupal
    
## Usage

Open your application's `Capfile` and make it begin like this:

    require 'rubygems'
    require 'railsless-deploy'
    require 'capistrano-drupal
    load    'config/deploy'

You should then be able to proceed as you would usually, you may want to familiarise yourself with the truncated list of tasks, you can get a full list with:

    $ cap -T