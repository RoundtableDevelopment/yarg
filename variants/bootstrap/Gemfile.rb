insert_into_file "Gemfile", after: /gem ['"]kaminari['"].*\n/ do
  <<-GEMS.strip_heredoc
    gem 'bootstrap', '~> 4.1.0'
    gem 'jquery-rails'
  GEMS
end

