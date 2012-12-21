
module CTT::Cli

  class Runner

    attr_reader    :commands, :uuid, :command, :url, :log
    attr_accessor  :configs, :suites


    # @param [Array] args
    def self.run(args)
      new(args).run
    end

    def initialize(args)
      @args = args

      banner = "Usage: orc [<options>] <command> [<args>]"
      @option_parser = OptionParser.new(banner)

      @configs  = Configs.new
      @commands = @configs.commands
      @suites   = Suites.new
      @uuid     = UUIDTools::UUID.random_create
      @log      = Logger.new(File.join(ENV["HOME"], ".orc/orc.log"), 'weekly')
      @url      = ENV['ORC_RESULTS_SERVER_URL'] ?
          format_url(ENV['ORC_RESULTS_SERVER_URL']) : RESULTS_SERVER_URL
    end

    def run
      #puts "the args: #{@args}"
      parse_global_options

      if @args.empty? && @options.empty?
        say(usage)
        exit(0)
      end

      if @options[:help]
        Command::Help.new(@args, self).run
        exit(0)
      end

      find, command, args = search_commands
      unless find
        say("invalid command. abort!", :red)
        exit(1)
      end

      @command = command
      execute(command, args)

    end

    def parse_global_options
      @options = {}
      opts = @option_parser

      opts.on("-v", "--version", "Show version") do
        @options[:version] = true
        say("orc %s" % [CTT::Cli::VERSION])
        exit(0)
      end

      opts.on("-h", "--help", "Show help message") do
        @options[:help] = true
      end

      begin
        @args = @option_parser.order!(@args)
      rescue
        say("invalid command. abort!", :red)
        exit(1)
      end
    end

    def usage
      @option_parser.to_s
    end

    def search_commands
      cmds = @commands.keys

      find = nil
      longest_cmd = ""
      args = []
      size = @args.size
      size.times do |index|

        longest_cmd = @args[0..(size - index - 1)].join(" ")
        find = cmds.index(longest_cmd)
        if find
          args = @args[(size - index)..-1]
          break
        end

      end
      [find, longest_cmd, args]
    end

    def execute(command, args)
      handler = get_command_handler(command, args)
      handler.run
    end

    def get_command_handler(command, args)
      # handle runtime commands
      #
      @configs.suites["suites"].keys.each do |s|
        if command =~ /#{s}/
          #pieces = command.split(" ")
          #pieces.insert(0, "") if pieces.size == 1
          #action, suite = pieces
          return Command::TestSuite.new(command, args, self)
        end
      end

      # handle user defined alias
      #
      # TODO

      # handle static commands
      #
      handler =
          case command
            when "help"
              Command::Help.new(args, self)
            when "add suite", "delete suite", "suites"
              Command::SuitesConfig.new(command, args, self)
            when "tests", "rerun"
              Command::MultipleTests.new(command, args, self)
            else
              nil
          end
    end

    def format_url(url)
      unless url =~ /^http/
        url = "http://#{url}"
      end
      url
    end
  end
end