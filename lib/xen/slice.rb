class Xen::Slice
  attr_accessor :name, :image, :config, :backups
  
  def self.find(*args)
    options = args.extract_options!
    case args.first
      when :all       then Xen::Config.find(:all, options).collect { |config| config.slice }
      when :running   then Xen::Instance.find(:all, options).collect { |instance| instance.slice }
      # Retrieve a Slice by name
      else            Xen::Config.find_by_name(args.first) && self.new(args.first)
    end
  end
  
  def self.all(options={})
    self.find(:all, options)
  end
  
  def initialize(*args)
    options = args.extract_options! # remove trailing hash (not used)
    @name = args.first
    @config = options[:config]
    @instance = options[:instance]
    @instance_cache_expires = Time.now
    @backups = Array(options[:backups])
  end

  def create_image(args)
    args = hash.collect{|k,v| "#{k}=#{v}"}
    Xen::Command.create_image
  end
  
  # Cache Xen instance info to reduce system calls to xm command.
  # It still needs to be checked regularly as operations like shutdown
  # and create can take a while.
  def instance
    if @instance_cache_expires > Time.now
      @instance
    else
      @instance_cache_expires = Time.now + Xen::INSTANCE_OBJECT_LIFETIME
      @instance = Xen::Instance.find(@name) if @name
    end
  end  

  # XXX We're assuming other processes aren't going to edit configs
  # This is reasonable in simple cases.
  def config
    @config ||= Xen::Config.find(name) if @name
  end
  
  def backups
    Xen::Backup.find(name)
  end

  def state
    self.instance ? :running : :stopped
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
  
  def config_newer_than_instance?
	  instance && config.updated_at > instance.start_time 
	end
	
	def save
	  @config.save
  end
  
end