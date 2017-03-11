# frozen_string_literal: true
source "https://rubygems.org"

gemspec

group :development do
  # Using coveralls branch to pull in simplecov 0.13.0 for ruby 2.4 support
  gem "coveralls",
    git: "https://github.com/tagliala/coveralls-ruby.git",
    branch: "update-simplecov-dependency"

  gem "guard", platforms: [:ruby_22, :ruby_23] # Guard no longer supports ruby 2.1
  gem "guard-minitest", platforms: [:ruby_22, :ruby_23]
  gem "guard-rubocop", platforms: [:ruby_22, :ruby_23]
  gem "pry-byebug", platforms: [:ruby_21, :ruby_22, :ruby_23]
  gem "yard"
end
