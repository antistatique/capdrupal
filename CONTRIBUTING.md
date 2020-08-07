# Developing on Capdrupal

* Issues should be filed at
https://github.com/antistatique/capdrupal/issues
* Pull requests can be made against
https://github.com/antistatique/capdrupal/pulls

## 📦 Repositories

Github repo

  ```bash
  git remote add github https://github.com/antistatique/capdrupal.git
  ```

## 🔧 Prerequisites

First of all, you will need to have the following tools installed
globally on your environment:

  * ruby
  * bundle
  * capistrano
  * gem

## 💎 Specify local.capdrupal Ruby gems in your Gemfile

For local development, you will need to use on your local checkout of `capdrupal`.
To achieve this goal, you may update your project `Gemfile` and use `gem "capdrupal", path: "/path/to/capdrupal"`.

Please **don't do that** as explain here https://rossta.net/blog/how-to-specify-local-ruby-gems-in-your-gemfile.html

Instead, use the `bundle config local` and declare a new `local.capdrupal` gem:

    ```bash
    bundle config local.capdrupal /path/to/capdrupal
    ```

Though convenient, using the `:path` option in our Gemfile to point to a local gem elsewhere on our machine sets us
up for three potential problems without automated prevention:

  * Committing a nonexistent lookup path on other machines
  * Failing to point to the correct repository branch
  * Failing to point to an existing git reference
