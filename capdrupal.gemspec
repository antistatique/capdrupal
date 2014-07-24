# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name         = 'capdrupal'
  spec.version      = '2.0.0'
  spec.license      = 'MIT'
  spec.authors  = [ "Simon Perdrisat", "Gilles Doge" ]
  spec.email    = 'gilles.doge@gmail.com'
  spec.homepage = %q{http://github.com/antistatique/capdrupal/}

  spec.platform     = Gem::Platform::RUBY
  spec.description  = <<-DESC
    A set of tasks for deploying Drupal 8 projects with Capistrano 3 and the help of Drush.
  DESC
  spec.summary      = 'A set of tasks for deploying Drupal 8 projects with Capistrano 3'


  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.files = `git ls-files`.split($/)
  specrequire_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.0', '>= 3.2.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.1'

end
