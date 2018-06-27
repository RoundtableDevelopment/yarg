insert_into_file 'Gemfile', "gem 'webpacker'\n", after: /["']kaminari['"]\n/

run 'bundle install'

rails_command 'webpacker:install'
rails_command 'webpacker:install:react'

insert_into_file 'Procfile', after: /development.log\n/ do
  'webpacker: bin/webpack-dev-server'
end

git add: '.'
git commit: %Q{ -m 'Initial webpacker set up for React.' }

