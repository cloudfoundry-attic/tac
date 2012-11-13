
module CTT::Cli
  class CliError < StandardError
    attr_reader :exit_code

    def initialize(*args)
      @exit_code = 1
      super(*args)
    end

    def self.error_code(code = nil)
      define_method(:error_code) { code }
    end

    def self.exit_code(code = nil)
      define_method(:exit_code) { code }
    end

    error_code(42)
  end

  class UnknownCommand       < CliError; error_code(100); end

end
