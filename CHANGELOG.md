# Capdrupal Changelog

## NEXT RELEASE

## 3.0.5 (2023-09-05)
 - Remove `rake` dependency following security issue (to follow capitrano requirement)

## 3.0.4 (2023-04-25)
 - add command `drupal:security:obscurity:files` to obfuscate Drupal sensitive files by deletion
 - add command `drupal:security:obscurity:htaccess` to obfuscate Drupal sensitive files by htaccess

## 3.0.3 (2023-03-14)
 - Only files directory must have permissions fixed to be writable, not all shared files.

## 3.0.2 (2022-12-22)
 - Allow Site directory to be configured
 - Optimize permissions related tasks

## 3.0.1 (2020-08-07)
 - Update the command `drupal:cache:clear` to be re-runnable after invoke

## 3.0.0 (2020-08-07)
 - Support for Drupal 8 & Drupal 9
 - Complete code refactoring

## 0.11.0 (2016-01-21)
 - Support for Drupal 8 & Drupal 9

## 0.10.0 (2015-04-24)
 - Task `deploy` do not clear cache, revert features, updatedb, etc. For this use `deploy:full` task

## 0.9.6 (2014-06-14)
  * Fix capistrano deps
