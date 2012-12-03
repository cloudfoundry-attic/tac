
module CTT::Cli::Command

  class TestSuite < Base

    #USER_INPUT               = "USER_INPUT"
    #TEST_SUITE_CONFIG_FILE   = "tac.yml"
    SUPPORT_OPTIONS          = {"--force" => "bypass git dirty state check"}

    include Interactive

    def initialize(command, args, runner)
      super(args, runner)

      pieces = command.split(" ")
      pieces.insert(0, "") if pieces.size == 1
      action, suite = pieces

      @action = action
      @suite = suite
      @configs = runner.configs
      @suites = runner.suites
    end

    def run
      @action = "test" if @action == ""
      eval(@action)
    end


    def list
      check_configuration
      get_suite_configs

      say("all subcommands for test suite: #{@suite}", :yellow)
      say("Options:", :yellow)
      SUPPORT_OPTIONS.each do |opt, helper|
        say("\t[#{opt}]   \t#{helper}")
      end
      nl

      @suite_configs["commands"].each do |command, details|
        say("#{@suite} #{command}", :green)
        say("\t#{details["desc"]}\n")
      end
    end

    def configure
      puts "configure #{@suite}"
      location = @configs.configs["suites"][@suite]["location"]
      location = "" if location == USER_INPUT
      invalid_input = true
      3.times do
        user_input = ask("suite: #{@suite} source directory:", :default => location).strip
        if user_input =~ /^~/
          user_input = File.expand_path(user_input)
        else
          user_input = File.absolute_path(user_input)
        end
        if Dir.exist?(user_input)
          if File.exist?(File.join(user_input, TEST_SUITE_CONFIG_FILE))
            invalid_input = false
            location = user_input
            break
          else
            say("the configure file: #{yellow(TEST_SUITE_CONFIG_FILE)} " +
                    "cannot be found under #{user_input}.")
          end
        else
          say("the directory: #{user_input} is invalid.")
        end
      end

      if invalid_input
        say("invalid inputs for 3 times. abort!", :red)
        exit(1)
      else
        @configs.configs["suites"][@suite]["location"] = location
        @configs.save
        say("configure suite: #{@suite} successfully.", :green)
      end
    end

    def test
      check_configuration
      parse_options
      check_if_dirty_state unless @options["--force"]
      get_suite_configs

      dependencies, command = parse_command

      threads = []
      pwd = Dir.pwd
      Dir.chdir(@suites.suites["suites"][@suite])
      threads << Thread.new do
        # dependency should be successful before run testing command
        say("preparing test suite: #{@suite}...")
        dependencies.each do |d|
          `#{d}`
          exit(1) unless $? == 0
        end

        say("\nrun command: #{yellow(command)}")
        system(command)
      end
      Dir.chdir(pwd)
      threads.each { |t| t.join }

      collector = ClientCollector.new(@runner.command, @suite, @runner)
      collector.post
    end

    def check_configuration
      unless @suites.suites["suites"].has_key?(@suite)
        say("suite configure file: #{@suites.file} did not has key: #{@suite}")
        exit(1)
      end
    end

    def check_if_dirty_state
      if dirty_state?
        say("\n%s\n" % [`git status`])
        say("Your current directory has some local modifications, " +
                "please discard or commit them first.\n" +
                "Or use #{yellow("--force")} to bypass git dirty check.")
        exit(1)
      end
    end

    def dirty_state?
      `which git`
      return false unless $? == 0

      Dir.chdir(@suites.suites["suites"][@suite])
      (File.directory?(".git") || File.directory?(File.join("..", ".git"))) \
        && `git status --porcelain | wc -l`.to_i > 0
    end

    def parse_options
      @options = {}
      opts = SUPPORT_OPTIONS.keys
      @args.each do |arg|
        if opts.index(arg)
          @options[arg] = true
          @args.delete(arg)
        end
      end
    end

    def parse_command
      subcmd = ""
      dependencies = []
      if @args.empty?
        subcmd =  @suite_configs["commands"]["default"]["exec"]
        dependencies = @suite_configs["commands"]["default"]["dependencies"]
      elsif @suite_configs["commands"].has_key?(@args[0])
        subcmd = @suite_configs["commands"][@args[0]]["exec"]
        dependencies = @suite_configs["commands"][@args[0]]["dependencies"]
        @args.delete(@args[0])
      else
        say("#{@args[0]} is not invalid sub-command, run as default command")
        subcmd = @suite_configs["commands"]["default"]["exec"]
        dependencies = @suite_configs["commands"]["default"]["dependencies"]
      end

      unless @args.empty?
        subcmd = subcmd + " " + @args.join(" ")
      end

      [dependencies, subcmd]
    end

    def get_suite_configs
      suite_configs_path = File.join(@suites.suites["suites"][@suite],
                                     CTT::Cli::TEST_SUITE_CONFIG_FILE)
      @suite_configs ||= YAML.load_file(suite_configs_path)
      unless @suite_configs.is_a?(Hash)
        say("invalid yaml format for file: #{suite_configs_path}", :red)
        exit(1)
      end
      @suite_configs
    end
  end
end