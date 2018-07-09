insert_into_file 'Gemfile', "gem 'pundit'\n", after: /["']devise['"]\n/

run 'bundle install'

generate 'pundit:install'

insert_into_file 'app/controllers/application_controller.rb', after: /ActionController::Base\n/ do
<<-EOF
  include Pundit
EOF
end

git add: '.'
git commit: %Q{ -m 'Initial pundit setup.' }
