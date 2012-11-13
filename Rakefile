require "fileutils"

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