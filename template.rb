require 'fileutils'
require 'shellwords'

YARG_REPO = 'https://github.com/RoundtableDevelopment/yarg.git'.freeze
RAILS_REQUIREMENT = '~> 5.2.0'.freeze

def build_app!
  # Template set up checks
  assert_minimum_rails_version
  add_template_repository_to_source_path

  # Copy root config files
  template 'ruby-version.tt', '.ruby-version', force: true
  template 'Gemfile.tt', 'Gemfile', force: true
  copy_file 'gitignore', '.gitignore', force: true
  template 'example.env.tt'
  copy_file 'Procfile'
  template 'README.md.tt', force: true

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

    # Copy variants as necessary
    apply 'variants/devise/template.rb'       if apply_devise?
    apply 'variants/pundit/template.rb'       if apply_devise? && apply_pundit?
    apply 'variants/skylight/template.rb'     if apply_skylight?
    apply 'variants/sentry/template.rb'       if apply_sentry?
    apply 'variants/simple_form/template.rb'  if apply_simple_form?
    apply 'variants/react/template.rb'        if apply_react?
    apply 'variants/active_storage/template.rb' if apply_active_storage?

    # This should run last
    apply 'variants/haml/template.rb'         if apply_haml?

    run 'bin/setup'

    binstubs = %w(annotate bundler)
    run "bundle binstubs #{binstubs.join(' ')} --force"

    git add: '.'
    git commit: %Q{ -m 'Completed app templating' }
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

def stop_spring
  run 'spring stop'
end

def apply_devise?
  @devise ||= yes?('Do you want to use Devise?')
end

def apply_skylight?
  @skylight ||= yes?('Do you want to use Skylight?')
end

def apply_haml?
  @haml ||= yes?('Do you want to use HAML?')
end

def apply_sentry?
  @sentry ||= yes?('Do you want to use Sentry?')
end

def apply_simple_form?
  @simple_form ||= yes?('Do you want to use Simple Form?')
end

def apply_react?
  @react ||= yes?('Do you want to use React?')
end

def apply_active_storage?
  @active_storage ||= yes?('Do you want to use Active Storage?')
end

def apply_pundit?
  @pundit ||= yes?('Do you want to use Pundit?')
end

build_app!
