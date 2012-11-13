
module CTT::Cli
  class Configs

    COMMANDS_CONFIG_PATH =
        File.absolute_path(File.join(File.dirname(__FILE__), "../../config/commands.yml"))

    attr_accessor :configs

    attr_reader   :commands

    def initialize
      load
      load_commands
      save
    end

    def load
      @configs = YAML.load_file(COMMANDS_CONFIG_PATH)
      @commands = @configs["commands"]
    end

    def save
      File.open(COMMANDS_CONFIG_PATH, "w") { |f| f.write YAML.dump(@configs) }
    end

    def load_commands
      commands = {}
      @configs["suites"].each do |suite, _|
        # for each suite, three commands should be added.
        # - configure suite
        # - suite [subcommand]
        # - list suite
        key = "configure #{suite}"
        commands[key] = {"usage" => key,
                         "desc"  => "configure test suite: #{suite} before running it"}

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