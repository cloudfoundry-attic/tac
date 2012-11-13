
module CTTExtensions

  def say(message, color = nil, sep = "\n")
    msg = message
    puts Paint[msg, color]
  end

  def nl
    puts ""
  end

  def err(message)
    raise CTT::Cli::CliError, message
  end

  def red(message)
    Paint[message, :red]
  end

  def yellow(message)
    Paint[message, :yellow]
  end

  def green(message)
    Paint[message, :green]
  end

  def cyan(message)
    Paint[message, :cyan]
  end
end

class Object
  include CTTExtensions
end
