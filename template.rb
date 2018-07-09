require 'fileutils'
require 'shellwords'

YARG_REPO = 'https://github.com/RoundtableDevelopment/yarg.git'.freeze
RAILS_REQUIREMENT = '~> 5.2.0'.freeze

def build_app!
  debug_print('Checking your environment setup...')
  # Template set up checks
  assert_minimum_rails_version
  add_template_repository_to_source_path

  debug_print('Copying root config files...')
  # Copy root config files
  template 'ruby-version.tt', '.ruby-version', force: true
  template 'Gemfile.tt', 'Gemfile', force: true
  copy_file 'gitignore', '.gitignore', force: true
  template 'example.env.tt'
  copy_file 'Procfile'
  template 'README.md.tt', force: true

  debug_print('Templating app...')
  # Copy base application files
  apply 'app/template.rb'
  apply "bin/template.rb"
  apply 'config/template.rb'
  apply 'lib/template.rb'
  apply 'spec/template.rb'

  after_bundle do
    git :init
    git add: '.'
    git commit: %Q{ -m 'Initial generator setup.' }

    stop_spring

    debug_print('Please select your application options...')
    select_variants
    debug_print('Implementing your selections...')

    # Copy variants as necessary
    apply 'variants/devise/template.rb'         if @devise
    apply 'variants/pundit/template.rb'         if @devise && @pundit
    apply 'variants/skylight/template.rb'       if @skylight
    apply 'variants/sentry/template.rb'         if @sentry
    apply 'variants/simple_form/template.rb'    if @simple_form
    apply 'variants/react/template.rb'          if @react
    apply 'variants/active_storage/template.rb' if @active_storage

    # This should run last since it converts all generated ERB
    # to HAML
    apply 'variants/haml/template.rb'           if @haml

    debug_print('Running bin/setup to finish setting up your environment...')
    run 'bin/setup'

    debug_print('Updating your binstubs')
    binstubs = %w(annotate bundler)
    run "bundle binstubs #{binstubs.join(' ')} --force"

    git add: '.'
    git commit: %Q{ -m 'Completed app templating' }

    debug_print('Success!')
  end
end

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("yarg-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      YARG_REPO,
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{yarg/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def select_variants
  @devise         = yes?('Do you want to use Devise for user authentication?', :blue)
  @pundit         = yes?('Do you want to use Pundit for user authorization?', :blue) if @devise
  @skylight       = yes?('Do you want to use Skylight for performance monitoring?', :blue)
  @skylight_token = ask('Enter your skylight token: ', :green) if @skylight
  @haml           = yes?('Do you want to use HAML instead of ERB view templates?', :blue)
  @sentry         = yes?('Do you want to use Sentry for error tracking?', :blue)
  @sentry_dsn     = ask('Enter your Sentry DSN url:') if @sentry
  @simple_form    = yes?('Do you want to use Simple Form for rails forms?', :blue)
  @react          = yes?('Do you want to use React?', :blue)
  @active_storage = yes?('Do you want to use Active Storage for storing files?', :blue)
end

def stop_spring
  run 'spring stop'
end

def debug_print(message = '')
  puts "==================="
  puts message
  puts "==================="
end

build_app!
