
require "spec_helper"

describe CTT::Cli::Command::Help do

  it "list help command" do
    args = "help abc def"
    output = `./bin/orc #{args}`
    keywords = ["help", "tests",
                "add suite <Test Suite Path> [alias]"]
    keywords.each do |w|
      output.should include w
    end
  end
end
