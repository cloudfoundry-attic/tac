
module CTT::Cli
  module Command
    class Base

      def initialize(args, runner)
        @args = args.dup
        @runner = runner
      end
    end
  end

end