module OodSupport
  # A helper module that describes the current running process
  module Process
    # Owner of current process
    # @return [User] owner of process
    def self.user
      User.new ::Process.uid
    end

    # Primary group of current process
    # @return [Group] group of process
    def self.group
      Group.new ::Process.gid
    end

    # List of groups current process is in
    # @return [Array<Group>] list of groups for process
    def self.groups
      ::Process.groups.map {|g| Group.new g}
    end

    # Whether user's groups changed since running process
    # @return [Boolean] whether groups changed
    def self.groups_changed?
      groups.sort != user.groups.sort
    end
  end
end
