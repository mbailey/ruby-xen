module Xen
  # General configuration for ruby-xen
  
  # Location of Xen config files
  XEN_DOMU_CONFIG_DIR = '/etc/xen'
  # XEN_DOMU_CONFIG_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec/fixtures/xen_domu_configs'))
  
  # We don't want out library to hit Xen too often (premature optimization perhaps?)
  # so we keep information about Xen instances in an object. Specify how long before
  # the object expires.
  INSTANCE_OBJECT_LIFETIME = 5 # seconds
  
  # General location for config file templates
  TEMPLATE_DIR = File.expand_path(File.dirname(__FILE__) + '/../lib/templates')
  
  # Extension for Xen domU config files
  CONFIG_FILE_EXTENSION = '.cfg'
  
  # Directory for backups of system images
  BACKUP_DIR='/var/xen_images'
  
  # File extension for backups
  BACKUP_FILE_EXT = '.tar'
  
  TEMPLATES_BASE = File.join(File.dirname(__FILE__), 'templates')
  
  XEN_TOOLS_CONFIG_FILE = '/etc/xen-tools/xen-tools.conf'
  
end

class Array #:nodoc:
  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)           # => {}
  #   options(1, 2, :a => :b) # => {:a=>:b}
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

class Hash #:nodoc:
  # Converts a Hash into an array of key=val formatted strings
  #
  # puts { :nics => 2, :vcpus => 1, :memory => 64, :dhcp => true }.to_args 
  #
  # produces:
  #
  # ["--memory=64", "--nics=2", "--vcpus=1", "--dhcp"]
  def to_args
    collect{|k,v| (v.to_s == 'true') ? "--#{k.to_s}" : "--#{k.to_s}=#{v}"}
  end
end

module Xen
  # DRY up some classes (children of Slice) with some module funkiness.
  module Parentable
    # Returns the parent Slice object (d) for a sub-object. 
    # We ensure d.instance.object_id == self.object_id
    # 
    # ==== Example
    #   i = Xen::Instance.all[2]
    #   s = i.slice
    #   i.object_id == s.instance.object_id # true
    #
    def slice
      d = Xen::Slice.new(:name => name)
      # Insert the current object into the newly created Slice's attributes
      d.instance_variable_set("@#{self.class.to_s.sub('Xen::','').downcase}", self)
      d
    end
  end
end

class String
  def underscorize
    self.sub("-", "__")
  end
  def ununderscorize
    self.sub("__", "-")
  end
end

# We want to use Rails's stringify_keys
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/reverse_merge"
class Hash #:nodoc:
  include ActiveSupport::CoreExtensions::Hash::Keys
  include ActiveSupport::CoreExtensions::Hash::ReverseMerge
end

require "#{File.dirname(__FILE__)}/xen/backup"
require "#{File.dirname(__FILE__)}/xen/command"
require "#{File.dirname(__FILE__)}/xen/config_file"
require "#{File.dirname(__FILE__)}/xen/host"
require "#{File.dirname(__FILE__)}/xen/instance"
require "#{File.dirname(__FILE__)}/xen/slice"
require "#{File.dirname(__FILE__)}/xen/xen_tools_conf"
require "#{File.dirname(__FILE__)}/xen/lvm"