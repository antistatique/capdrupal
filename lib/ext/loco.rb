##
# Loco Translate Recipe
#
# Manage your Drupal translations with Locolize.biz.
# @see https://www.drupal.org/project/loco_translate
##
namespace :load do
  task :defaults do
    set :loco_push, {
      po_sync_lang: 'en',
      po_file: './config/languages/loco-en.po',
    }
    set :loco_pull, {
      languages: ['fr', 'de', 'en'],
      status: 'translated',
    }
  end
end

namespace 'drupal:loco' do
  desc 'Upload PO translation file to Loco'
  task :push do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        execute :drush, 'loco_translate:push', "--language=#{fetch(:loco_push)[:po_sync_lang]}", "../#{(fetch(:loco_push)[:po_file])}"
      end
    end
  end

  desc 'Pull translation(s) from Loco to Drupal'
  task :pull do
    on roles(:app) do
      within release_path.join(fetch(:app_path)) do
        fetch(:loco_pull)[:languages].each do |lang|
          execute :drush, 'loco_translate:pull', "#{lang}", "--status=#{fetch(:loco_pull)[:status]}"
        end
      end
    end
  end
end
