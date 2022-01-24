require 'open3'

module OodSupport
  module ACLs
    # Object describing an NFSv4 ACL
    class Nfs4ACL < ACL
      # The binary used to get the file ACLs
      GET_FACL_BIN = 'nfs4_getfacl'

      # The binary used to set the file ACLs
      SET_FACL_BIN = 'nfs4_setfacl'

      # Name of owner for this ACL
      # @return [String] owner name
      attr_reader :owner

      # Name of owning group for this ACL
      # @return [String] group name
      attr_reader :group

      # Get ACL from file path
      # @param path [String] path to file or directory
      # @raise [InvalidPath] file path doesn't exist
      # @raise [BadExitCode] the command line called exited with non-zero status
      # @return [Nfs4ACL] acl generated from path
      def self.get_facl(path:)
        path = Pathname.new path
        raise InvalidPath, "invalid path: #{path}" unless path.exist?
        stat = path.stat
        acl, err, s = Open3.capture3(GET_FACL_BIN, path.to_s)
        raise BadExitCode, err unless s.success?
        parse(acl, owner: User.new(stat.uid), group: Group.new(stat.gid))
      end

      # Add ACL to file path
      # @param path [String] path to file or directory
      # @param entry [Nfs4Entry] entry to add to file
      # @raise [InvalidPath] file path doesn't exist
      # @raise [BadExitCode] the command line called exited with non-zero status
      # @return [Nfs4ACL] new acl of path
      def self.add_facl(path:, entry:)
        path = Pathname.new path
        raise InvalidPath, "invalid path: #{path}" unless path.exist?
        _, err, s = Open3.capture3(SET_FACL_BIN, '-a', entry.to_s, path.to_s)
        raise BadExitCode, err unless s.success?
        get_facl(path: path)
      end

      # Remove ACL from file path
      # @param path [String] path to file or directory
      # @param entry [Nfs4Entry] entry to remove from file
      # @raise [InvalidPath] file path doesn't exist
      # @raise [BadExitCode] the command line called exited with non-zero status
      # @return [Nfs4ACL] new acl of path
      def self.rem_facl(path:, entry:)
        path = Pathname.new path
        raise InvalidPath, "invalid path: #{path}" unless path.exist?
        _, err, s = Open3.capture3(SET_FACL_BIN, '-x', entry.to_s, path.to_s)
        raise BadExitCode, err unless s.success?
        get_facl(path: path)
      end

      # Modify in-place an entry for file path
      # @param path [String] path to file or directory
      # @param old_entry [Nfs4Entry] old entry to modify in-place in file
      # @param new_entry [Nfs4Entry] new entry to be replaced with
      # @raise [InvalidPath] file path doesn't exist
      # @raise [BadExitCode] the command line called exited with non-zero status
      # @return [Nfs4ACL] new acl of path
      def self.mod_facl(path:, old_entry:, new_entry:)
        path = Pathname.new path
        raise InvalidPath, "invalid path: #{path}" unless path.exist?
        _, err, s = Open3.capture3(SET_FACL_BIN, '-m', old_entry.to_s, new_entry.to_s, path.to_s)
        raise BadExitCode, err unless s.success?
        get_facl(path: path)
      end

      # Set ACL (overwrites original) for file path
      # @param path [String] path to file or directory
      # @param acl [Nfs4ACL] ACL to overwrite original with
      # @raise [InvalidPath] file path doesn't exist
      # @raise [BadExitCode] the command line called exited with non-zero status
      # @return [Nfs4ACL] new acl of path
      def self.set_facl(path:, acl:)
        path = Pathname.new path
        raise InvalidPath, "invalid path: #{path}" unless path.exist?
        _, err, s = Open3.capture3(SET_FACL_BIN, '-s', acl.to_s, path.to_s)
        raise BadExitCode, err unless s.success?
        get_facl(path: path)
      end

      # @param owner [#to_s] name of owner
      # @param group [#to_s] name of group
      # @see ACL#initialize
      def initialize(owner:, group:, **kwargs)
        super(kwargs.merge(default: false))
        @owner = owner.to_s
        @group = group.to_s
      end

      # Check if queried principle has access to resource
      # @param principle [User, Group] principle to check against
      # @param permission [Symbol] permission to check against
      # @return [Boolean] does principle have access?
      def allow?(principle:, permission:)
        # Check in array order
        ordered_check(principle: principle, permission: permission, owner: owner, group: group)
      end

      # Convert object to hash
      # @return [Hash] the hash describing this object
      def to_h
        super.merge owner: owner, group: group
      end

      private
        # Use Nfs4Entry for entry objects
        def self.entry_class
          Nfs4Entry
        end
    end

    # Object describing single NFSv4 ACL entry
    class Nfs4Entry < ACLEntry
      # Valid types for an ACL entry
      VALID_TYPE = %i[ A U D L ]

      # Valid flags for an ACL entry
      VALID_FLAG = %i[ f d p i S F g ]

      # Valid permissions for an ACL entry
      VALID_PERMISSION = %i[ r w a x d D t T n N c C o y ]

      # Regular expression used when parsing ACL entry string
      REGEX_PATTERN = %r[^(?<type>[#{VALID_TYPE.join}]):(?<flags>[#{VALID_FLAG.join}]*):(?<principle>\w+)@(?<domain>[\w\.\-]*):(?<permissions>[#{VALID_PERMISSION.join}]+)$]

      # Type of ACL entry
      # @return [Symbol] type of acl entry
      attr_reader :type

      # Flags set on ACL entry
      # @return [Array<Symbol>] flags on acl entry
      attr_reader :flags

      # Domain of ACL entry
      # @return [String] domain of acl entry
      attr_reader :domain

      # Permissions of ACL entry
      # @return [Array<Symbol>] permissions of acl entry
      attr_reader :permissions

      # @param type [#to_sym] type of acl entry
      # @param flags [Array<#to_sym>] list of flags for entry
      # @param domain [#to_s] domain of principle
      # @param permissions [Array<#to_sym>] list of permissions for entry
      # @see ACLEntry#initialize
      def initialize(type:, flags:, domain:, permissions:, **kwargs)
        @type = type.to_sym
        @flags = flags.map(&:to_sym)
        @domain = domain.to_s
        @permissions = permissions.map(&:to_sym)
        super(kwargs)
      end

      # Is this an "allow" ACL entry
      # @return [Boolean] is this an allow entry
      def is_allow?
        type == :A
      end

      # Is this a "deny" ACL entry
      # @return [Boolean] is this a deny entry
      def is_deny?
        type == :D
      end

      # Do the requested args match this ACL entry?
      # @param principle [User, Group, #to_s] requested principle
      # @param permission [#to_sym] requested permission
      # @param owner [String] owner of corresponding ACL
      # @param group [String] owning group of corresponding ACL
      # @raise [ArgumentError] principle isn't {User} or {Group} object
      # @return [Boolean] does this match this entry
      def match(principle:, permission:, owner:, group:)
        principle = User.new(principle) if (!principle.is_a?(User) && !principle.is_a?(Group))
        return false unless has_permission?(permission: permission)
        # Ignore domain, I don't want or care to check for domain matches
        p = self.principle
        p = owner if user_owner_entry?
        p = group if group_owner_entry?
        if (principle.is_a?(User) && group_entry?)
          principle.groups.include?(p)
        elsif (principle.is_a?(User) && user_entry?) || (principle.is_a?(Group) && group_entry?)
          principle == p
        elsif other_entry?
          true
        else
          false
        end
      end

      # Is this a user-specific ACL entry
      # @return [Boolean] is this a user entry
      def user_entry?
        !group_entry? && !other_entry?
      end

      # Is this a group-specific ACL entry
      # @return [Boolean] is this a group entry
      def group_entry?
        flags.include? :g
      end

      # Is this an other-specific ACL entry
      # @return [Boolean] is this an other entry
      def other_entry?
        principle == "EVERYONE"
      end

      # Is this the owner ACL entry
      # @return [Boolean] is this the owner entry
      def user_owner_entry?
        user_entry? && principle == "OWNER"
      end

      # Is this the owning group ACL entry
      # @return [Boolean] is this the owning group entry
      def group_owner_entry?
        group_entry? && principle == "GROUP"
      end

      # Does this entry have the requested permission
      # @param permission [#to_sym] the requested permission
      # @return [Boolean] found this permission
      def has_permission?(permission:)
        permissions.include? permission.to_sym
      end

      # Convert object to string
      # @return [String] the string describing this object
      def to_s
        "#{type}:#{flags.join}:#{principle}@#{domain}:#{permissions.join}"
      end

      private
        # Parse an entry string into input parameters
        def self.parse_entry(entry)
          e = REGEX_PATTERN.match(entry.to_s.strip) do |m|
            {
              type:        m[:type],
              flags:       m[:flags].chars,
              principle:   m[:principle],
              domain:      m[:domain],
              permissions: m[:permissions].chars
            }
          end
          e ? e : raise(InvalidACLEntry, "invalid entry: #{entry}")
        end
    end
  end
end
