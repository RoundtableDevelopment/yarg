source_dir = 'variants/devise/spec'.freeze

insert_into_file 'Gemfile', "gem 'devise'\n", after: /["']kaminari['"]\n/

run 'bundle install'

generate 'devise:install'

generate :devise, 'User'

# Since we can expect to need to style the login and
# signup pages, we go ahead and generate these views
generate 'devise:views', '-v', 'registrations', 'sessions'

copy_file "#{source_dir}/factories/user.rb", 'spec/factories/user.rb'
copy_file "#{source_dir}/models/user_spec.rb", 'spec/models/user_spec.rb', force: true
copy_file "#{source_dir}/support/helpers/session_helpers.rb", 'spec/support/helpers/session_helpers.rb'
copy_file "#{source_dir}/support/helpers.rb", 'spec/support/helpers.rb'
copy_file "#{source_dir}/support/devise.rb", 'spec/support/devise.rb'

git add: '.'
git commit: %Q{ -m 'Initial devise setup.' }
