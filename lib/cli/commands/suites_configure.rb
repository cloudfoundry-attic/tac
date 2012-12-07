
module CTT::Cli::Command

  class SuitesConfig < Base

    #TEST_SUITE_CONFIG_FILE   = "tac.yml"

    include Interactive, CTT::Cli

    def initialize(command, args, runner)
      super(args, runner)

      pieces = command.split(" ")
      pieces.insert(0, "list") if pieces.size == 1
      @action, _ = pieces

      @configs = @runner.configs
      @suites = @runner.suites
    end

    def run
      eval(@action)
    end

    def add
      puts "add suite"
      #location = @configs.configs["suites"][@suite]["location"]
      location = ""
      invalid_input = true
      3.times do
        user_input = ask("test suite source directory").strip
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
      end

      load_test_suite_config(location)
      suite_alias = @suite_config["name"]

      @suites.suites["suites"][suite_alias] = location
      @suites.save
      say("configure suite: #{suite_alias} successfully.", :green)
    end

    def list
      print_suites
    end

    def load_test_suite_config(location)
      path = File.join(location, TEST_SUITE_CONFIG_FILE)
      @suite_config = YAML.load_file(path)
      unless @suite_config.is_a?(Hash)
        say("#{path} is not valid yml file.", :red)
        exit(1)
      end

      # validate test suite config file
      validate_points = %w(name commands results)
      validate_points.each do |p|
        unless @suite_config.keys.include?(p)
          say("field: '#{p}' is not found in config file #{path}", :red)
          exit(1)
        end
      end
    end

    def print_suites
      header = ["alias", "path"]
      rows = []
      @suites.suites["suites"].each do |suite_alias, path|
        rows << [suite_alias, path]
      end
      table = Terminal::Table.new(:headings => header, :rows => rows)
      puts table
    end

  end
end
