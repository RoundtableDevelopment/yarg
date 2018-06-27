source_paths.unshift(File.dirname(__FILE__))

copy_file 'app/assets/javascripts/application.js', 'app/assets/javascripts/application.js', force: true
directory 'app/assets/stylesheets', force: true
remove_file 'app/assets/stylesheets/application.css'

copy_file 'app/controllers/pages_controller.rb'

template 'app/views/layouts/application.html.erb.tt', force: true
copy_file 'app/views/pages/home.html.erb'

route "root to: 'pages#home'"
