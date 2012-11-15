
module CTT::Cli
  class Configs

    attr_accessor :configs

    attr_reader   :commands, :suites

    def initialize
      @suites = Suites.new.suites
      load_commands
    end

    def load_commands
      @commands = STATIC_COMMANDS.dup
      commands = {}
      @suites["suites"].each do |suite, _|
        # for each suite, three commands should be added.
        # - configure suite
        # - suite [subcommand]
        # - list suite
        commands[suite] = {"usage" => "#{suite} [subcommand]",
                           "desc"  => "run default test for test suite: #{suite}," +
                                      " if no subcommand is specified"}

        key = "list #{suite}"
        commands[key] = {"usage" => key,
                         "desc"  => "list all available subcommands for test suite: #{suite}"}
      end

      @commands.merge!(commands)
    end
  end
end