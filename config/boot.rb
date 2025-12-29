ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Load SimpleCov early for accurate coverage measurement (Rails 7.1+ compatibility)
# See: https://github.com/simplecov-ruby/simplecov/issues/1082
require "simplecov" if ENV["COVERAGE"] || ENV["CI"]
