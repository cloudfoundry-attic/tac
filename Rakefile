require "fileutils"
require "rake"
require "rspec/core/rake_task"

desc "build gem file"
task :build do
  config_path = File.expand_path("./config")
  unless Dir.exists?(config_path)
    FileUtils.mkdir(config_path)
  end
  src   = File.join(config_path, "template/commands.yml")
  dest  = File.join(config_path, "commands.yml")
  FileUtils.cp(src, dest)
  system("gem build tac-cli.gemspec -V")
end

if defined?(RSpec)
  namespace :spec do
    SPEC_OPTS = %w(--format documentation --colour)

    desc "Run unit tests"
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.pattern = "spec/unit/**/*_spec.rb"
      t.rspec_opts = SPEC_OPTS
    end
  end

  desc "Run tests"
  task :spec => %w(spec:unit)
end
