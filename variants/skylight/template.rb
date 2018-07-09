insert_into_file 'Gemfile', "gem 'skylight'\n", after: /["']kaminari['"]\n/

run 'bundle install'

unless @skylight_token.blank?
  run "bundle exec skylight setup #{skylight_token}"

  # Add the skylight token to the .env file
end

git add: '.'
git commit: %Q{ -m 'Initial Skylight setup.' }
