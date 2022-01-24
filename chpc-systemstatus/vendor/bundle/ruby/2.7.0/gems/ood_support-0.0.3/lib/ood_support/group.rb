require 'etc'

module OodSupport
  # A helper object describing a Unix group's details
  class Group
    include Comparable

    # The id of the group
    # @return [Integer] the group id
    attr_reader :id

    # The name of the group
    # @return [String] the group name
    attr_reader :name

    # @param group [Integer, #to_s] the group id or name
    def initialize(group = Process.group)
      if group.is_a?(Integer)
        @id = group
        @name = Etc.getgrgid(@id).name
      else
        @name = group.to_s
        @id = Etc.getgrnam(@name).gid
      end
    end

    # The comparison operator for sorting values
    # @param other [#to_s] group to compare against
    # @return [Integer] how groups compare
    def <=>(other)
      name <=> other
    end

    # Checks whether two Group objects have the same group as well as that the
    # object is in the Group class
    # @param other [Group] group to compare against
    # @return [Boolean] whether same objects
    def eql?(other)
      self.class == other.class && self == other
    end

    # Generates a hash value for this object
    # @return [Integer] hash value of object
    def hash
      [self.class, name].hash
    end

    # Convert object to string using group name as string value
    # @return [String] the group name
    def to_s
      name
    end
  end
end
