# OodSupport

Open OnDemand gem that provides a set of support objects to interface with the
local OS installed on the HPC Center's web node.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ood_support'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ood_support

## Usage

### User

Provides a simplified system-level user object that can be used to determine
user's id, groups, shell, home directory...

```ruby
require 'ood_support'

# Generate OodSupport::User object from user name
u = OodSupport::User.new 'user1'

# User name
u.name
#=> "user1"

# User id
u.id
#=> 1000

# User shell
u.shell
#=> "/bin/bash"

# Array of groups user is in
u.groups
#=> [<OodSupport::Group ...>, <OodSupport::Group ...>, ...]

# Names of groups user is in
u.groups.map(&:name)
#=> ["primary_group", "group1", "group2"]

# Name of user's primary group
u.group.name
#=> "primary_group"

# Whether user is in group called "group15"
u.in_group? "group15"
#=> false

# Use it in a string
puts "Hello #{u}!"
#=> "Hello user1!"
```

You can generate the `OodSupport::User` object from a user name, user id,
another `OodSupport::User`, or from the running process:

```ruby
require 'ood_support'

# Generate OodSupport::User object from user name
u1 = OodSupport::User.new 'user1'

# Generate OodSupport::User object from user id
u2 = OodSupport::User.new 1000

# Generate OodSupport::User object from another object
u3 = OodSupport::User.new u1

# Generate OodSupport::User from running process
me = OodSupport::User.new
```

### Group

Provides a simplified system-level group object that can be used to determine
group id and group name.

```ruby
require 'ood_support'

# Generate OodSupport::Group object from group name
g = OodSupport::Group.new 'group1'

# Get group id
g.id
#=> 100

# Get group name
g.name
#=> 'group1'

# Generate OodSupport::User object from user name
u = OodSupport::User.new 'user1'

# Sort the list of groups user is in
u.groups.sort.map(&:name)
#=> ["a_group", "b_group", "c_group"]
```

You can generate the `OodSupport::Group` object from a group name, group id,
another `OodSupport::Group` object, or from the running process:

```ruby
require 'ood_support'

# Generate OodSupport::Group object from group name
g1 = OodSupport::Group.new 'group1'

# Generate OodSupport::Group object from group id
g2 = OodSupport::Group.new 100

# Generate OodSupport::Group object from another object
g3 = OodSupport::Group.new g1

# Generate OodSupport::Group from running process
me = OodSupport::Group.new
```

### Process

Provides a simplified interface to the running process that can be used to
determine owner of the process as well as whether the owner's groups have
changed since the process started.

```ruby
require 'ood_support'

# Get owner of process
OodSupport::Process.user
#=> <OodSupport::User ...>

# Get primary group of process
OodSupport::Process.group
#=> <OodSupport::Group ...>

# Get list of groups process is currently in
OodSupport::Process.groups
#=> [<OodSupport::Group ...>, <OodSupport::Group ...>, ...]

# Whether owner's groups changed since process started
OodSupport::Process.groups_changed?
#=> false
```

### ACLs

#### NFSv4 File ACLs

Allows reading and writing of NFSv4 file ACL permissions.

To access a file's ACL:

```ruby
# Get file ACL
acl = OodSupport::ACLs::Nfs4ACL.get_facl(path: "/path/to/file")

# Check if user has read access to file
acl.allow?(principle: OodSupport::User.new("user1"), permission: :r)
#=> true

# Check if group has write access to file
# NB: A user of this group may *actually* have access to write to this file
acl.allow?(principle: OodSupport::Group.new("group1"), permission: :w)
#=> false
```

To add an ACL permission to a file:

```ruby
# Create a new ACL entry
entry = OodSupport::ACLs::Nfs4Entry.new(type: :A, flags: [], principle: "user2", domain: "osc.edu", permissions: [:r, :w])

# or you can pass it a properly formatted string...
entry = OodSupport::ACLs::Nfs4Entry.parse("A::user2@osc.edu:rw")

# Add this entry to the file ACLs
acl = OodSupport::ACLs::Nfs4ACL.add_facl(path: "/path/to/file", entry: entry)

# Check that this added entry changes access
acl.allow?(principle: OodSupport::User.new("user2"), permission: :r)
#=> true
```

To remove an ACL permission from a file:

```ruby
# Get file ACL
acl = OodSupport::ACLs::Nfs4ACL.get_facl(path: "/path/to/file")

# Choose the entry we want to remove from the array of entries
entry = acl.entries.first

# Remove this entry from the file
new_acl = OodSupport::ACLs::Nfs4ACL.rem_facl(path: "/path/to/file", entry: entry)

# Check that this entry removal changes access
new_acl.allow?(principle: OodSupport::User.new("user2"), permission: :r)
#=> false
```

##### File ACL Methods

List of class methods on the `Nfs4ACL` object used to access/modify a file's
ACL. For all class methods an `Nfs4ACL` object is created and returned.

```ruby
# Get the file/directory ACLs for a given path
Nfs4ACL::get_facl(path: p)

# Add an ACL entry to the given file/directory ACLs
Nfs4ACL::add_facl(path: p, entry: e)

# Remove an ACL entry from the given file/directory ACLs
Nfs4ACL::rem_facl(path: p, entry: e)

# Modify in-place an ACL entry from the given file/directory ACLs
Nfs4ACL::mod_facl(path: p, old_entry: e1, new_entry: e2)

# Set the whole ACL (overwrites original) for a given file/directory
Nfs4ACL::set_facl(path: p, acl: a)
```

#### Posix File ACLs

Allows reading and writing of Posix file ACL permissions.

To access a file's ACL:

```ruby
# Get file ACL
acl = OodSupport::ACLs::PosixACL.get_facl path: "/path/to/file"

# Check if user has read access to file
acl.allow?(principle: OodSupport::User.new("user1"), permission: :r)
#=> true

# Check if group has write access to file
# NB: A user of this group may *actually* have access to write to this file
acl.allow?(principle: OodSupport::Group.new("group1"), permission: :w)
#=> false
```

To add an ACL permission to a file:

```ruby
# Create a new ACL entry
entry = OodSupport::ACLs::PosixEntry.new(flag: :user, principle: "user2", permissions: [:r, :w, :-])

# or you can pass it a properly formatted string...
entry = OodSupport::ACLs::PosixEntry.parse("user:user2:rw-")

# Add this entry to the file ACLs
acl = OodSupport::ACLs::PosixACL.add_facl(path: "/path/to/file", entry: entry)

# Check that this added entry changes access
acl.allow?(principle: OodSupport::User.new("user2"), permission: :r)
#=> true
```

To remove an ACL permission from a file:

```ruby
# Get file ACL
acl = OodSupport::ACLs::PosixACL.get_facl(path: "/path/to/file")

# Choose the entry we want to remove from the array of entries
entry = acl.entries.detect {|e| e.user_entry? && e.principle == "user2"}

# Remove this entry from the file
new_acl = OodSupport::ACLs::PosixACL.rem_facl(path: "/path/to/file", entry: entry)

# Check that this entry removal changes access
new_acl.allow?(principle: OodSupport::User.new("user2"), permission: :r)
#=> false
```

##### File ACL Methods

List of class methods on the `PosixACL` object used to access/modify a file's
ACL. For all class methods an `PosixACL` object is created and returned.

```ruby
# Get the file/directory ACLs for a given path
PosixACL::get_facl(path: p)

# Add an ACL entry to the given file/directory ACLs
PosixACL::add_facl(path: p, entry: e)

# Remove an ACL entry from the given file/directory ACLs
PosixACL::rem_facl(path: p, entry: e)

# Clear all extended ACLs for the given file/directory
PosixACL::clear_facl(path: p)
```
## Contributing

1. Fork it ( https://github.com/[my-github-username]/ood_support/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
