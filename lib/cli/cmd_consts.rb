
module CTT::Cli
  STATIC_COMMANDS = {"help" => {"usage" => "help",
                                "desc" => "list all available commands"},
                     "tests" => {"usage" => "tests",
                                 "desc" => "run default multiple test suites."},
                     "add suites" => {"usage" => "add suite <Test Suite Path> [alias]",
                                      "desc" => "add specific test suite to tac, " +
                                                 "and one alias can be given to resolve naming conflict"}}
end
