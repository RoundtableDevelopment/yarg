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

  apply 'app/template.rb'
  apply 'config/template.rb'
  apply 'lib/template.rb'

  after_bundle do
    git :init
    git add: '.'
    git commit: %Q{ -m 'Initial generator setup.' }

    stop_spring

    apply 'variants/devise/template.rb' if apply_devise?
    apply 'variants/skylight/template.rb' if apply_skylight?

    run 'bundle binstubs bundler --force'

    # rails_command db:create:all'
    # rails_command db:migrate'
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

build_app!
