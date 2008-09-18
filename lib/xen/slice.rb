class Xen::Slice
  attr_accessor :name, :image, :config

  def initialize(name)
    @name = name
    @config = Xen::Config.find(name)
    @instance = Xen::Instance.find(name)
    @instance_cache_expires = Time.now + Xen::INSTANCE_OBJECT_LIFETIME
    @image = Xen::Image.find(name)
  end

  def self.create(args)
    args = hash.collect{|k,v| "#{k}=#{v}"}
  end
  
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
  
  # Cache Xen instance info to reduce system calls to xm command.
  def instance
    if @instance_cache_expires > Time.now
      @instance
    else
      @instance_cache_expires = Time.now + Xen::INSTANCE_OBJECT_LIFETIME
      @instance = Xen::Instance.find(@name)
    end
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
  

  
end