# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "standard/rake"
require "yard"

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
  t.warning = false
end

task test: :spec

task default: %i[spec standard]

namespace :doc do
  desc "Build docs"
  task :build do
    sh "bundle exec yard doc"
  end

  desc "Publish to gh-pages"
  task :publish do
    puts "Publishing docs"
    require "fileutils"
    sh "git checkout gh-pages"
    sh "git commit -vam 'Update documentation'"
    sh "git push origin gh-pages"
    sh "git checkout -"
  end
end
