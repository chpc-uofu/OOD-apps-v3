require 'forwardable'
require 'etc'

module OodSupport
  # A helper object used to query information about a system user from the
  # local host
  class User
    include Comparable

    extend Forwardable

    # @!method name
    #   The user name
    #   @return [String] the user name
    # @!method uid
    #   The user's id
    #   @return [Integer] the user id
    # @!method gecos
    #   The user's real name
    #   @return [String] the real name
    # @!method dir
    #   The user's home directory
    #   @return [String] the home path
    # @!method shell
    #   The user's shell
    #   @return [String] the shell
    delegate [:name, :uid, :gecos, :dir, :shell] => :@passwd

    alias_method :id, :uid

    alias_method :home, :dir

    # @param user [Integer, #to_s] user id or name
    def initialize(user = Process.user)
      @passwd = user.is_a?(Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user.to_s)
    end

    # Determine whether user is part of specified group
    # @param group [Group] group to check
    # @return [Boolean] whether user is in group
    def in_group?(group)
      groups.include? Group.new(group)
    end

    alias_method :member_of_group?, :in_group?

    # Provide primary group of user
    # @return [Group] primary group of user
    def group
      groups.first
    end

    # List of all groups that user belongs to
    # @return [Array<Group>] list of groups user is in
    def groups
      @groups ||= get_groups
    end

    # The comparison operator for sorting values
    # @param other [#to_s] user to compare against
    # @return [Integer] how users compare
    def <=>(other)
      name <=> other
    end

    # Checks whether two User objects have the same user as well as that the
    # object is in the User class
    # @param other [User] user to compare against
    # @return [Boolean] whether same objects
    def eql?(other)
      self.class == other.class && self == other
    end

    # Generates a hash value for this object
    # @return [Integer] hash value of object
    def hash
      [self.class, name].hash
    end

    # Convert object to string using user name as string value
    # @return [String] the user name
    def to_s
      name
    end

    private
      # Use `id` to get list of groups as the /etc/group file can give
      # erroneous results
      def get_groups
        `id -G #{name}`.split(' ').map {|g| Group.new(g.to_i)}
      end
  end
end
