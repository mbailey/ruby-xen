module Xen
  class Slice
    attr_accessor :name, :image, :config_file, :backups
  
    def self.find(*args)
      options = args.extract_options!
      case args.first
        when :all       then Xen::ConfigFile.find(:all, options).collect { |config_file| new config_file.name }
        when :running   then Xen::Instance.find(:all, options).collect { |instance| new instance.name }
        # Retrieve a Slice by name
        else            Xen::ConfigFile.find_by_name(args.first) && new(args.first)
      end
    end
  
    def self.all(options={})
      self.find(:all, options)
    end
  
    def initialize(*args)
      options = args.extract_options! # remove trailing hash (not used)
      @name = args.first
      @config_file = options[:config_file]
      @instance = options[:instance]
      @instance_cache_expires = Time.now
      @backups = Array(options[:backups])
    end

    def create_image(args)
      args = hash.collect{|k,v| "#{k}=#{v}"}
      Xen::Command.create_image(*args)
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
  
    def create_backup(version=nil)
      Xen::Backup.create(name, version)
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
  
  end
end

module Xen
  
  # puts Xen::XenToolsConf.load.to_hash.inspect
  
  # XXX move into ruby-xen.rb
  XEN_TOOLS_CONFIG_FILE = '/etc/xen-tools/xen-tools.conf'
  
  class XenToolsConf

    # XXX underscorize :install-method, install-source, copy_cmd, tar-cmd
    attr_accessor :dir, :lvm, :install__method, :install__source, :copy_cmd,  
                  :tar_cmd, :debootstrap__cmd, :size, :memory, :swap, :noswap,
                  :fs,    
                  :dist, :image, :gateway,       
                  :netmask, :broadcast, :dhcp, :cache, :passwd, :accounts, 
                  :kernel, :initrd, :mirror, :ext3_options, :ext2_options, 
                  :xfs_options, :reiser_options, :boot, :serial_device, 
                  :disk_device, :output, :extension
                
    def initialize(*args)
    end
    
    def self.find(file=nil)
      file ||= Xen::XEN_TOOLS_CONFIG_FILE
      xtc = new # Create a new XenToolsConf object
      xtc.load_from_config_file(File.readlines(file))
      xtc
    end
    
    def load_from_config_file(file_contents)
      file_contents.reject! { |line| line.match /^\s*#/ } # Ignore commented out lines
      file_contents.grep(/(.*) = (.*)/).each { |setting|
        setting.scan(/\s*(.+?)\s*=\s*([^#]+)/).each { |match|
          key, val = match
          key.strip!
          val.strip!          
          instance_variable_set("@#{key.underscorize}", val) 
        }
      }
    end
    
    def to_hash
      self.instance_variables.inject({}) { |m, variable_name| 
        m[variable_name.sub('@','')] = instance_variable_get(variable_name); m 
      }
    end
    
    def to_file
      template = ERB.new(IO.read(File.join(TEMPLATES_BASE, 'xen-tools.conf.erb')))
      template.result(binding)
    end
    
    def save(filename=nil)
      filename ||= Xen::XEN_TOOLS_CONFIG_FILE
      File.open(filename, 'w') do |f|
        f.write(to_file)
      end
      # XXX check for errors
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

