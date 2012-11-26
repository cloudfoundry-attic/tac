
module CTT::Cli
  class TestReport

    attr_reader :summary

    def initialize(xml_file)
      unless File.exists?(xml_file)
        say("Test result file: #{xml_file} does not exist. abort!", :red)
        exit(1)
      end

      begin
        @doc = LibXML::XML::Document.file(xml_file)
      rescue Exception => e
        say("Test result file: #{xml_file} is not a valid xml document. abort!", :red)
        exit(1)
      end
    end

    def parse
      @summary = {:total => 0,
                  :failed => 0,
                  :pending => 0,
                  :duration => 0.0,
                  :failed_cases => [],
                  :pending_cases => []}

      cases = @doc.find("//case")
      @summary[:total] = cases.size
      cases.each do |c|
        get_duration(c)
        get_failed_case(c)
        get_pending_case(c)
      end
    end

    def get_duration(case_node)
      # duration
      duration = case_node.find_first("duration")
      @summary[:duration] += duration.content.to_f
    end

    def get_failed_case(case_node)
      # failed
      failed = case_node.find_first("errorDetails")
      if failed
        @summary[:failed] += 1
        @summary[:failed_cases] << case_node.find_first("rerunCommand").content
      end
    end

    def get_pending_case(case_node)
      # pending
      pending = case_node.find_first("skipped")
      if pending.content == "true"
        @summary[:pending] += 1
        @summary[:pending_cases] << case_node.find_first("testName").content
      end
    end
  end
end
