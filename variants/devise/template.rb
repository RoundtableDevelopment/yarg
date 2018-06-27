insert_into_file 'Gemfile', "gem 'devise'\n", after: /["']kaminari['"]\n/

run 'bundle install'

generate 'devise:install'

insert_into_file(
  'config/initializers/devise.rb', 
  "  config.secret_key = Rails.application.credentials.secret_key_base\n", 
  before: /^end/
)

generate :devise, 'User'

# Since we can expect to need to style the login and
# signup pages, we go ahead and generate these views
generate 'devise:views', '-v', 'registrations', 'sessions'

git add: '.'
git commit: %Q{ -m 'Initial devise setup.' }
