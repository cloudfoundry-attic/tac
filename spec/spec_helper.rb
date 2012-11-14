
require "rspec/core"
require "fileutils"

$:.unshift(File.expand_path("../../lib", __FILE__))
require "cli"

RSpec.configure do |c|
  c.before(:each) do
    config_path = File.expand_path("./config")
    unless Dir.exists?(config_path)
      FileUtils.mkdir(config_path)
    end
    src   = File.join(config_path, "template/commands.yml")
    dest  = File.join(config_path, "commands.yml")
    FileUtils.cp(src, dest)
  end

  c.color_enabled = true
end
