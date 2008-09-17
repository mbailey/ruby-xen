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

module Xen
  # Location of Xen config files
  XEN_DOMU_CONFIG_DIR = '/etc/xen'
  # XEN_DOMU_CONFIG_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec/fixtures/xen_domu_configs'))
  
  # We don't want out library to hit Xen too often (premature optimization perhaps?)
  # so we keep information about Xen instances in an object. Specify how long before
  # the object expires.
  INSTANCE_OBJECT_LIFETIME = 1
  
  TEMPLATE_DIR = File.expand_path(File.dirname(__FILE__) + '/../lib/templates')
  
  # Extension for Xen domU config files
  CONFIG_FILE_EXTENSION = '.cfg'
  
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
      d = Xen::Slice.new(name)
      # Insert the current object into the newly created Slice's attributes
      d.instance_variable_set("@#{self.class.to_s.sub('Xen::','').downcase}", self)
      d
    end
  end
end

require "#{File.dirname(__FILE__)}/xen/backup"
require "#{File.dirname(__FILE__)}/xen/command"
require "#{File.dirname(__FILE__)}/xen/config"
require "#{File.dirname(__FILE__)}/xen/slice"
require "#{File.dirname(__FILE__)}/xen/host"
require "#{File.dirname(__FILE__)}/xen/image"
require "#{File.dirname(__FILE__)}/xen/instance"