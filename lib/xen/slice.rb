module Xen
  class Slice
    attr_accessor :name, :image, :config_file, :backups
  
    def self.find(*args)
      options = args.extract_options!
      case args.first
        when :all       then Xen::ConfigFile.find(:all, options).collect { |config_file| new :name => config_file.name }
        when :running   then Xen::Instance.find(:all, options).collect { |instance| new :name => instance.name }
        # Retrieve a Slice by name
        else            Xen::ConfigFile.find_by_name(args.first) && new(:name => args.first)
      end
    end
  
    def self.all(options={})
      self.find(:all, options)
    end
  
    def initialize(*args)
      options = args.extract_options! 
      @name = options[:name]
      @config_file = options[:config_file]
      @instance = options[:instance]
      @instance_cache_expires = Time.now
      @backups = Array(options[:backups])
    end

    def create_image(*args)
      options = args.extract_options!.stringify_keys
      
      # Load default values for options that have not been set
      options.reverse_merge! Xen::XenToolsConf.find.to_hash 
      
      # Set some derived options
      options.reverse_merge! 'hostname' => name # Name host after this slice
      options['dhcp'] = true unless options['ip']
      options['swap'] ||= options['memory'].to_i * 2
      if options['root_pass']
        options['role'] = 'passwd'
        options['role-args'] = options['root_pass']
      end
      if options['tarball']
        options['install-method'] = 'tar'
        options['install-source'] = options['tarball']
        options.delete('dist')
      end
      
      args = %w(hostname dist memory size
                force boot
                role role-args roledir
                dir lvm mirror 
                ip mac netmask broadcast gateway dhcp
                swap
                accounts admins cache config fs image image-dev initrd 
                keep kernel modules output install hooks partitions 
                passwd tar-cmd extension swap-dev noswap ide arch 
                install-method install-source template evms)
      # Remove options that are not in allowed argument list
      options.keys.each { |key| options.delete(key) unless args.include?(key) }
      
      Xen::Command.create_image(options)
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

    # XXX We're assuming other processes aren't going to edit config_files
    # This is reasonable in simple cases.
    def config_file
      @config_file ||= Xen::ConfigFile.find(name) if @name
    end
  
    def backups
      Xen::Backup.find(name)
    end
  
    def create_backup(options = {})
      Xen::Backup.create(name, :options)
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
  
    def config_file_newer_than_instance?
  	  instance && config_file.updated_at > instance.start_time 
  	end
	
  	def save
  	  @config_file.save
    end
    
    def root_disk
      config_file.vbds.detect { |vbd| vbd.name == "#{name}-disk" } unless config_file.nil?
    end
    
    # Primary IP
    def ip
      config_file.vifs[0].ip
    end
  
  end
end



