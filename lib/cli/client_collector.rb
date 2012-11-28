

module CTT::Cli
  class ClientCollector

    def initialize
      @info = {}
    end

    def get_os
      @info[:os] = RUBY_PLATFORM

      case 1.size
        when 4
          @info[:platform] = "32bit"
        when 8
          @info[:platform] = "64bit"
        else
          @info[:platform] = nil
      end
    end


  end
end
