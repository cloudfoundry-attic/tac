
module CTT::Cli
  STATIC_COMMANDS = {"help" => {"usage" => "help",
                                "desc" => "list all available commands"},
                     "tests" => {"usage" => "tests",
                                 "desc" => "run default multiple test suites."},
                     "add suite" => {"usage" => "add suite",
                                      "desc" => "add specific test suite to tac"},
                     "delete suite" => {"usage" => "delete suite",
                                        "desc" => "list all test suites configuration"},
                     "suites" => {"usage" => "suites",
                                  "desc" => "list all test suites configuration"}}

end
