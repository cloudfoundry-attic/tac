
module CTT::Cli::Command

  class MultipleTests < Base

    def initialize(args, runner)
      super(args, runner)
      @suites = @runner.suites
    end

    def run
      say("run multiple test suites", :green)

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
