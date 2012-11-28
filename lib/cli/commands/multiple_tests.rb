
module CTT::Cli::Command

  class MultipleTests < Base

    MAX_RERUN_TIMES     =   10

    include CTT::Cli

    def initialize(command, args, runner)
      super(args, runner)
      @suites = @runner.suites
      @command = command
    end

    def run
      eval(@command)
    end

    def tests
      say("run multiple test suites", :green)
      run_tests
      show_summary
    end

    def rerun
      say("rerun failed cases for multiple test suites", :green)
      rerun_tests
      show_summary(true)
    end

    def rerun_tests
      index = 1
      @suites.suites["suites"].each do |name, _|
        say("#{index}) start to run failed cases for test suite: #{name}\n", :yellow)
        args = @args.insert(0, @command)
        cmd = TestSuite.new(name, args, @runner)
        cmd.run
        index += 1
      end
    end

    def run_tests
      index = 1
      @suites.suites["suites"].each do |name, _|
        say("#{index}) start to run test suite: #{name}\n", :yellow)
        cmd = TestSuite.new(name, @args, @runner)
        cmd.run
        index += 1
      end
    end

    def show_summary(rerun = false)
      summary = {:total => 0,
                 :failed => 0,
                 :pending => 0,
                 :duration => 0.0,
                 :failed_cases => {},
                 :pending_cases => {}
      }
      @suites.suites["suites"].each do |name, path|
        suite_config_path = File.absolute_path(File.join(path, TEST_SUITE_CONFIG_FILE))
        suite_config = YAML.load_file(suite_config_path)
        unless suite_config["results"]
          say("no results field in #{suite_config_path}. abort!", :red)
          exit(1)
        end

        result_path   = File.join(path, suite_config["results"])
        if rerun
          result_file = File.join(get_rerun_folder(result_path), TEST_RESULT_FILE)
        else
          result_file   = File.join(result_path, TEST_RESULT_FILE)
        end

        report        = TestReport.new(result_file)
        report.parse

        summary[:total]         += report.summary[:total]
        summary[:failed]        += report.summary[:failed]
        summary[:pending]       += report.summary[:pending]
        summary[:duration]      += report.summary[:duration]
        summary[:failed_cases][name]    = report.summary[:failed_cases]
        summary[:pending_cases][name]   = report.summary[:pending_cases]
      end

      print_cases_summary(summary)
      print_failed_cases(summary)

    end

    def print_cases_summary(summary)
      say("\nFinished in #{format_time(summary[:duration])}")

      color = :green
      color = :yellow if summary[:pending] > 0
      color = :red if summary[:failed] > 0
      say("#{summary[:total]} examples, #{summary[:failed]} failures, #{summary[:pending]} pendings", color)
    end

    def print_failed_cases(summary)
      unless summary[:failed_cases].empty?
        say("\nFailures:")
        summary[:failed_cases].each do |suite, cases|
          say("  Test Suite: #{suite}", :yellow)
          cases.each do |c|
            say("    #{c.strip}", :red)
          end
        end
        say("execute #{yellow("rerun")} command to run all failed cases.")
      end
    end

    def format_time(t)
      time_str = ''
      time_str += (t / 3600).to_i.to_s + " hours " if t > 3600
      time_str += (t % 3600 / 60).to_i.to_s + " minutes " if t > 60
      time_str += (t % 60).to_f.round(2).to_s + " seconds"
      time_str
    end

    def get_rerun_folder(result_folder)
      rerun_folder = result_folder
      i = MAX_RERUN_TIMES
      while(i > 0)
        if File.exists?(File.join(result_folder, "rerun#{i}"))
          rerun_folder = File.join(result_folder, "rerun#{i}")
          break
        end
        i -= 1
      end
      rerun_folder
    end
  end
end
