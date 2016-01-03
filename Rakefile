require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"
require "yard"

YARD::Rake::YardocTask.new do |t|
  t.files = ["README.md", "lib/**/*.rb"]
end

Rake::TestTask.new(:spec) do |t|
  t.libs << "spec"
  t.libs << "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
end

RuboCop::RakeTask.new

task default: [:spec, :rubocop]
