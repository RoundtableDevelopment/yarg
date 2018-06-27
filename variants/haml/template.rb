insert_into_file 'Gemfile', "gem 'haml-rails', '~> 1.0'\n", after: /["']kaminari['"]\n/

run 'bundle install'

run 'HAML_RAILS_DELETE_ERB=true bin/rails haml:erb2haml'

git add: '.'
git commit: %Q{ -m 'Initial HAML setup.' }