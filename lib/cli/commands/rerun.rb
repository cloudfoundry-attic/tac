
module CTT::Cli::Command

  class RerunTests < Base

    include CTT::Cli

    def initialize(args, runner)
      super(args, runner)
      @suites = @runner.suites
    end

    def run
      say("rerun failed cases", :green)
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
  end
end
