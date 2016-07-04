require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "yard"

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
  t.warning = false
end

task test: :spec

RuboCop::RakeTask.new

task default: [:spec, :rubocop]

namespace :doc do
  desc "Generate docs and publish to gh-pages"
  task :publish do
    require "fileutils"
    sh "yard doc"
    sh "git checkout gh-pages"
    sh "cp -R doc/* ."
    sh "git commit -vam 'Update documentation'"
    sh "git push origin gh-pages"
    sh "git checkout -"
  end
end
