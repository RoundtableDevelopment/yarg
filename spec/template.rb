copy_file 'spec/rails_helper.rb'
copy_file 'spec/spec_helper.rb'

copy_file 'spec/support/factory_bot.rb'
copy_file 'spec/support/vcr.rb'
copy_file 'spec/system/view_root_path_spec.rb'

empty_directory_with_keep_file 'spec/controllers'
empty_directory_with_keep_file 'spec/factories'
empty_directory_with_keep_file 'spec/models'
empty_directory_with_keep_file 'spec/services'
empty_directory_with_keep_file 'spec/fixtures'

remove_dir 'test'

