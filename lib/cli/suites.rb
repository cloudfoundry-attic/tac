

module CTT::Cli
  class Suites

    SUITES_CONFIG_FILE =
        File.absolute_path(File.join(ENV["HOME"], ".tac/suites.yml"))

    attr_accessor :suites

    def initialize
      load
      save
    end

    def load
      unless Dir.exists?(File.dirname(SUITES_CONFIG_FILE))
        Dir.mkdir(File.dirname(SUITES_CONFIG_FILE))
      end

      if File.exists?(SUITES_CONFIG_FILE)
        @suites = YAML.load_file(SUITES_CONFIG_FILE)
      else
        @suites = {"suites" => {}}
      end
    end

    def save
      File.open(SUITES_CONFIG_FILE, "w") { |f| f.write YAML.dump(@suites) }
    end
  end
end