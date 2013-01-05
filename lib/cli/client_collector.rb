

module CTT::Cli
  class ClientCollector

    def initialize(command, suite, runner)
      @log  = runner.log
      @url  = runner.url
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
      payload[:file]        = File.open(@tar_file_path, "r")
      payload[:multipart]   = true

      #retry 3 times
      3.times do
        begin
          response = RestClient.post("#{@url}/upload", payload)
          @log.debug("post results. URL: #{@url}/upload, payload: #{payload}," +
                         " response code: #{response.code}")
          break if response.code == 200
        rescue Exception => e
          @log.error("post results. URL: #{@url}/upload. Error: #{e.to_s}")
        end
      end
      FileUtils.rm(payload[:file].path)
    end

    def collect
      get_os
      get_ruby_version
      get_test_reports
      get_git_info
      get_uuid
      get_timestamp
      get_hostname
      get_ipaddr
    end

    def get_hostname
      @info[:hostname] = `hostname`.strip
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

    def get_git_info
      pwd = Dir.pwd
      Dir.chdir(@suite_path)
      begin
        @info[:git_hash] = `git log --oneline -n 1`
        @info[:email]    = `git config --get user.email`
        @info[:username] = `git config --get user.name`
      rescue
      end
      Dir.chdir(pwd)
    end

    def get_ruby_version
      @info[:ruby_version] = `ruby -v`
    end

    def get_test_reports
      @suite_path = File.absolute_path(@suites.suites["suites"][@suite])
      suite_config_path = File.join(@suite_path, TEST_SUITE_CONFIG_FILE)
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
      @tar_file_path = zip_test_reports(report_path)
    end

    def zip_test_reports(reports_path)

      temp_file_path = File.join(Dir.tmpdir, "reports-#{@uuid}.tgz")
      pwd = Dir.pwd
      Dir.chdir(File.dirname(reports_path))
      `tar czf #{temp_file_path} #{File.basename(reports_path)} 2>&1`
      unless $?.exitstatus == 0
        say("fail to tarball test reports. abort!", :red)
        FileUtils.rm(temp_file_path)
        exit(1)
      end
      Dir.chdir(pwd)

      temp_file_path
    end
  end
end
