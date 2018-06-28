source_dir = 'variants/active_storage'.freeze

insert_into_file 'app/assets/javascripts/application.js', after: /rails-ujs\n/ do 
  "//= require activestorage\n"
end

copy_file "#{source_dir}/direct_uploads.js",    'app/assets/javascripts/direct_uploads.js'
copy_file "#{source_dir}/direct_uploads.scss",  'app/assets/stylesheets/direct_uploads.scss'

insert_into_file 'app/assets/stylesheets/application.scss', after: /@import ['"]style["'];\n/ do
  "@import 'direct_uploads';\n" 
end

rails_command 'active_storage:install'

git add: '.'
git commit: %Q{ -m 'Initial Active Storage setup.' }

