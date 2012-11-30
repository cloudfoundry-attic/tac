
module CTT::Cli::Command
  class Help < Base

    def run
      @commands = @runner.commands
      @commands.each do |command, details|
        say(details["usage"], :green)
        say("\t#{details["desc"]}\n")
      end
    end
  end
end