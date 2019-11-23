##
# Search API Recipe
#
# Provides a generic framework for modules offering search capabilities.
# @see https://www.drupal.org/project/search_api
##
namespace 'drupal:sapi' do
  desc 'Clears one or all search indexes and marks them for reindexing.'
  task :clear do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, "sapi-c"
      end
    end
  end

  desc 'Indexes items for one or all enabled search indexes.'
  task :index do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, "sapi-i"
      end
    end
  end
end
