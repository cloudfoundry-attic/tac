
module CTT::Cli::Command

  class MultipleTests < Base

    include CTT::Cli

    def initialize(args, runner)
      super(args, runner)
      @suites = @runner.suites
    end

    def run
      say("run multiple test suites", :green)
      #run_tests
      show_summary
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

    def show_summary
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
        result_file   = File.join(path, suite_config["results"], TEST_RESULT_FILE)
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
  end
end
