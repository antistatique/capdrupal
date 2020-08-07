# Documentation for maintainers

Since this is a Ruby tool used by PHP programmers it might be a good idea to document
some things. 

## Making a release

Checklist for making a release: 

- Write changelog 
- Update version number in `capdrupal.gemspec`
- Commit those 2 changes and create a new tag with the version number
- Make a [new release with GitHub](https://github.com/antistatique/capdrupal/releases/new)
- Build the gem with `gem build capdrupal.gemspec`
- Push the gem to rubygems.org: `gem push capdrupal-X.X.X.gem` 
- Add the `capdrupal-X.X.X.gem` to the GitHub release 

