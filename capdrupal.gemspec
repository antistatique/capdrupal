lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capdrupal'
  spec.version       = '8.0.0'
  spec.authors       = ['Kevin Wenger', 'Yann Lugrin', 'Gilles Doge', 'Toni Fisler', 'Simon Perdrisat', 'Robert Wohleb', 'Kim Pepper']
  spec.email         = ['hello@antistatique.net']

  spec.description   = <<-DESC
    A set of tasks for deploying Drupal 8 and Drupal 7 projects with Capistrano and the help of Drush.
  DESC
  spec.summary       = 'A set of tasks for deploying and managing Drupal projects with Capistrano'
  spec.homepage      = %q{http://github.com/antistatique/capdrupal/}
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'NOT ALLOWED'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.5.0'
  spec.add_dependency 'capistrano-composer', '~> 0.0.6'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0.0'
end
