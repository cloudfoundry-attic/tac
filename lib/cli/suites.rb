

module CTT::Cli
  class Suites

    SUITES_CONFIG_FILE =
        File.absolute_path(File.join(ENV["HOME"], ".orc/suites.yml"))

    attr_accessor :suites

    attr_reader   :file

    def initialize
      load
      save
    end

    def load
      @file = SUITES_CONFIG_FILE
      unless Dir.exists?(File.dirname(@file))
        Dir.mkdir(File.dirname(@file))
      end

      if File.exists?(@file)
        @suites = YAML.load_file(@file)
      else
        @suites = {"suites" => {}}
      end
    end

    def save
      File.open(@file, "w") { |f| f.write YAML.dump(@suites) }
    end

  end
end
