module Xen
  
  # Location of Xen config files
  XEN_DOMU_CONFIG_DIR = '/etc/xen'
  # XEN_DOMU_CONFIG_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec/fixtures/xen_domu_configs'))
  
  # We don't want out library to hit Xen too often (premature optimization perhaps?)
  # so we keep information about Xen instances in an object. Specify how long before
  # the object expires.
  INSTANCE_OBJECT_LIFETIME = 1   
                                
  
  class Commands
    def self.xm_info
      `xm info`
    end
    def self.xen_list_images
      `xen-list-images`
    end    
  end
  
  
  class Host
    attr_reader :host, :machine, :total_memory, :free_memory
    
    def initialize
      result = Xen:Commands.xm_info
      result.scan(/(\S+)\s*:\s*([^\n]+)/).each do |i,j| 
        instance_variable_set("@#{i}", j)
      end
    end
  end
  

  class Domain
    attr_accessor :name, :image, :config
  
    def initialize(name)
      @name = name
      @config = Xen::Config.find(name)
      @instance = Xen::Instance.find(name)
      @image = Xen::Image.find(name)
    end
  
    def instance
      if @instance && @instance.object_expires > Time.now
        @instance
      else
        @instance = Xen::Instance.find(@name)
      end
    end
    
    def self.find(*args)
      options = args.extract_options!
      case args.first
        when :all       then Xen::Config.find(:all, options).collect { |config| config.domain }
        when :running   then Xen::Instance.find(:all, options).collect { |instance| instance.domain }
        # Retrieve a Domain by name
        else            Xen::Config.find_by_name(args.first) && self.new(args.first)
      end
    end
    
    def all(options={})
      self.find(:all, options)
    end
  
    def running?
      self.instance ? true : false
    end
    
    def start
      Xen::Instance.create(@name)
      @instance = Xen::Instance.find(@name)
    end
    
    def stop
      Xen::Instance.shutdown(@name)
      @instance = Xen::Instance.find(@name)
    end
    
  end

  # DRY up some classes (children of Domain) with some module funkiness.
  module Parentable
    # Returns the parent Domain object (d) for a sub-object. 
    # We ensure d.instance.object_id == self.object_id
    # 
    # ==== Example
    #   i = Xen::Instance.all[2]
    #   d = i.domain
    #   # i.object_id == d.instance.object_id
    #
    def domain
      d = Xen::Domain.new(name)
      d.instance_variable_set("@#{self.class.to_s.sub('Xen::','').downcase}", self)
      d
    end
  end

  # The Xen config files on disk
  class Config
    include Xen::Parentable
    attr_accessor :name, :kernel, :ramdisk, :memory, :root, :disk, :vif, :on_poweroff, :on_reboot, :on_crash, :extra
  
    def initialize(*args)
      options = args.extract_options!
      @name = args.first
      @kernel = options[:kernel] || nil
      @ramdisk = options[:ramdisk] || nil
      @memory = options[:memory] || nil
      @root = options[:root] || nil
      @disk = options[:disk] || nil
      @vif = options[:vif] || nil
      @on_poweroff = options[:on_poweroff] || nil
      @on_reboot = options[:on_reboot] || nil
      @on_crash = options[:on_crash] || nil
      @extra = options[:extra] || nil
    end
  
    def self.find(*args)
      options = args.extract_options!
      case args.first
        when :all       then all
        else            find_by_name(args.first)
      end
    end

    def self.all
      config_files = Dir.glob("#{Xen::XEN_DOMU_CONFIG_DIR}/*.cfg")
      config_files.collect do |filename|
        create_from_config_file(File.read(filename))
      end
    end    
  
    def self.find_by_name(name)
      return new('Domain-0') if name == 'Domain-0' 
      filename = "#{Xen::XEN_DOMU_CONFIG_DIR}/#{name}.cfg"
      create_from_config_file(File.read(filename))
    end
    
    def self.create_from_config_file(config)
      name, kernel, ramdisk, memory, root, disk, vif, on_poweroff, on_reboot, on_crash, extra = nil
      eval(config)
      new(name, :disk => disk, :kernel => kernel, :ramdisk => ramdisk, :memory => memory, :root => root, :disk => disk, :vif => vif, :on_poweroff => on_poweroff, :on_reboot => on_reboot, :on_crash => on_crash, :extra => extra)
    end
    
    def save
      puts "I saved the config!"
    end
    
  end


  class Image
    include Xen::Parentable
    attr_accessor :name
  
    def initialize(name)
      @name = name
    end
  
    def self.find(name)
      new name
    end
  end


  class Instance
    include Xen::Parentable
    attr_reader :name, :domid, :memory, :cpu_time, :vcpus, :state, :start_time, :object_expires
  
    def initialize(name, options={})
      @name       = name
      @domid      = options[:domid] || nil 
      @memory     = options[:memory] || nil
      @cpu_time   = options[:cpu_time] || nil
      @vcpus      = options[:vcpus] || nil
      @state      = options[:state] || nil
      @start_time = options[:start_time] || nil
      @object_expires = Time.now + Xen::INSTANCE_OBJECT_LIFETIME
    end
    
    def self.find(*args)
      options = args.extract_options!
      case args.first
        when :all       then all
        else            find_by_name(args.first)
      end
    end
  
    def self.all
      result = `xm list`
      # XXX check for failed command
      result_array = result.split("\n")
      result_array.shift
      result_array.collect do |domain|
        name, domid, memory, vcpus, state, cpu_time = domain.scan(/[^ ,]+/)
        new(name, :domid => domid, :memory => memory, :cpu_time => cpu_time)
      end
    end
  
    def self.find_by_name(name)
      all.detect{|domain| domain.name == name.to_s }
    end
  
    # XXX Rails version - we need some error checking! 
    #
    # def self.find_by_name(name, options)
    #   if result = find_every(options)
    #     result.detect{ |domain| domain.name == name }
    #   else
    #     raise RecordNotFound, "Couldn't find domain with name=#{name}"
    #   end
    # end
    
    def self.create(name)
      output = `xm create #{name}.cfg`
      $? == 0 ? true : false
    end
    
    def self.shutdown(name)
      output = `xm shutdown #{name}`
      $? == 0 ? true : false
    end
    
    # A convenience wrapper for <tt>find(:dom0)</tt>.</tt>.
    def self.dom0(*args)
      find_by_name(:dom0)
    end
  
    def uptime
      start_time ? Time.now - start_time : nil
    end
  
    def running?
      output = `xm list #{name}`
      $? == 0 ? true : false
    end
  
    def reboot
      `xm reboot #{name}`
      $? == 0 ? true : false
    end
  
    def destroy
    end
  
    def pause
    end
  
  end

  class Backup
    include Xen::Parentable
  end
  
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