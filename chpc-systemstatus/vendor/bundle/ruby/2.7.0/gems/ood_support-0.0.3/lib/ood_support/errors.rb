module OodSupport
  # The root exception class that all OodSupport-specific exceptions inherit
  # from
  class Error < StandardError; end

  # An exception raised when attempting to access a path that doesn't exist on
  # local file system
  class InvalidPath < Error; end

  # An exception raised when attempting to run a command that exits with an
  # exit code other than 0
  class BadExitCode < Error; end

  # An exception raised when attempting to parse an ACL entry from a string
  class InvalidACLEntry < Error; end
end
