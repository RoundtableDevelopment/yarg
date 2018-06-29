# source_paths.unshift(File.dirname(__FILE__))

template 'config/database.yml.tt', force: true
copy_file 'config/puma.rb', force: true

apply "config/environments/development.rb"
apply "config/environments/production.rb"
apply "config/environments/test.rb"

copy_file 'config/initializers/friendly_id.rb'
copy_file 'config/initializers/generators.rb', force: true
copy_file 'config/initializers/kaminari.rb'
copy_file 'config/initializers/meta_tags.rb'
copy_file 'config/initializers/rotate_log.rb'
