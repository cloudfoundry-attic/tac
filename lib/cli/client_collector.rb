

module CTT::Cli
  class ClientCollector

    def initialize(command, suite, runner)
      @info = {}
      @suite  = suite
      @suites = runner.suites
      @uuid   = runner.uuid

      @info[:suite]   = @suite
      @info[:command] = command
    end

    def post
      collect

      payload = @info.dup
      payload[:results_file]  = @tar_file
      payload[:multipart]     = true

      #retry 3 times
      3.times do
        begin
          response = RestClient.post("#{RESULTS_SERVER_URL}/tac/upload", payload)
        rescue
        end
        break if response.code == 200
      end
      @tar_file.unlink
    end

    def collect
      get_os
      get_test_reports
      get_uuid
      get_timestamp
      get_hostname
      get_username
      get_ipaddr
    end

    def get_hostname
      @info[:hostname] = `hostname`.strip
    end

    def get_username
      @info[:username] = Etc.getlogin
    end

    def get_ipaddr
      @info[:ip] = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
    end

    def get_uuid
      @info[:uuid] = @uuid.to_s
    end

    def get_timestamp
      @info[:time] = Time.now.getutc.to_i
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


    def get_test_reports
      suite_config_path = File.absolute_path(File.join(@suites.suites["suites"][@suite], TEST_SUITE_CONFIG_FILE))
      suite_config = YAML.load_file(suite_config_path)
      unless suite_config["results"]
        say("no results field in #{suite_config_path}. abort!", :red)
        exit(1)
      end
      report_path = File.absolute_path(File.join(@suites.suites["suites"][@suite], suite_config["results"]))
      unless File.exists?(report_path)
        say("report path did not exists. abort!", :red)
        exit(1)
      end
      @tar_file = zip_test_reports(report_path)
    end

    def zip_test_reports(reports_path)
      tar_file = Tempfile.new(%w(reports .tgz))
      `tar czf #{tar_file.path} #{reports_path} 2>&1`
      unless $?.exitstatus == 0
        say("fail to tarball test reports. abort!", :red)
        tar_file.unlink
        exit(1)
      end
      tar_file
    end


  end
end
