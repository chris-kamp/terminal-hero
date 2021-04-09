require "logger"
require "tmpdir"

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
