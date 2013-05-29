# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name         = 'capdrupal'
  s.version      = '0.9.0'
  s.platform     = Gem::Platform::RUBY
  s.description  = <<-DESC
    A set of tasks for deploying Drupal projects with Capistrano and the help of Drush.
    Based on the work at https://github.com/previousnext/capistrano-drupal}
  DESC
  s.summary      = 'A set of tasks for deploying Drupal projects with Capistrano'

  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "README.markdown",
    "VERSION",
    "capdrupal.gemspec",
    "lib/capdrupal.rb"
  ]
  s.require_paths = 'lib'

  s.add_dependency 'capistrano', ">= 2.13.5","<= 2.15.4"
  s.add_dependency 'railsless-deploy', "~> 1.1.2"

  s.authors  = [ "Simon Perdrisat", "Gilles Doge", "Robert Wohleb", "Kim Pepper" ]
  s.email    = 'gilles.doge@gmail.com'
  s.homepage = %q{http://github.com/antistatique/capdrupal/}
end
