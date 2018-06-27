Rails.application.config do |config|
  config.generators do |g|
    g.helper          false
    g.javascripts     false
    g.stylesheets     false
    g.test_framework :rspec
  end
end