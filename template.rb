require 'fileutils'
require 'shellwords'

YARG_REPO = 'https://github.com/RoundtableDevelopment/yarg.git'.freeze
RAILS_REQUIREMENT = '~> 5.2.0'.freeze

def build_app!
  assert_minimum_rails_version
  assert_postgresql
  add_template_repository_to_source_path
  template 'ruby-version.tt', '.ruby-version', force: true
  template 'Gemfile.tt', force: true

  apply "variants/bootstrap/template.rb" if apply_bootstrap?

  after_bundle do
    puts "Hey we bundled"
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

def assert_postgresql
  return if IO.read("Gemfile") =~ /^\s*gem ['"]pg['"]/
  
  fail Rails::Generators::Error,
       "This template requires PostgreSQL, "\
       "but the pg gem isn’t present in your Gemfile."
end

def apply_bootstrap?
  yes?('Do you want to use bootstrap?')
end

build_app!
