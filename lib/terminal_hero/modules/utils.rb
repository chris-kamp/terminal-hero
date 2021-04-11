begin
  require "logger"
  require "tmpdir"
rescue LoadError => e
  # Display load errors using puts (not calling external methods which may not have been loaded)
  puts "It appears that a dependency was unable to be loaded: "
  puts e.message
  puts "Please try installing dependencies mannually by running the command "\
  "\"bundle install\" from within the installation directory."
  puts "If you installed this application as a gem, you could try reinstalling it by "\
  "running \"gem uninstall terminal_hero\" followed by \"gem install terminal_hero\""
  exit
end

# A module containing general utility methods
module Utils
  # Returns a value "collared" within a given range
  def self.collar(min, val, max)
    return [[min, val].max, max].min
  end

  # Clones a hash, then clones each of its values (but not any deeper values)
  def self.depth_two_clone(hash)
    clone = hash.dup
    clone.each { |key, value| clone[key] = value.dup }
    return clone
  end

  # Logs an error to a log file in the user's OS's global temp directory and
  # returns the path to the file for display to the user.
  def self.log_error(e)
    temp_directory = Dir.mktmpdir("/terminal-hero-logs")
    log_file = File.open(File.join(temp_directory, "th-error.log"), "w")
    logger = Logger.new(log_file)
    logger.error("An error occurred: #{e.full_message}")
    return File.path(log_file)
  end
end
