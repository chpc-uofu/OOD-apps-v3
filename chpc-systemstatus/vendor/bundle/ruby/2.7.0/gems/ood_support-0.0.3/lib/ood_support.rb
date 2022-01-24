require 'ood_support/version'
require 'ood_support/errors'
require 'ood_support/user'
require 'ood_support/group'
require 'ood_support/process'
require 'ood_support/acl'
require 'ood_support/acl_entry'

# The main namespace for ood_support
module OodSupport
  # A namespace to hold all subclasses of {ACL} and {ACLEntry}
  module ACLs
    require 'ood_support/acls/nfs4'
    require 'ood_support/acls/posix'
  end
end
