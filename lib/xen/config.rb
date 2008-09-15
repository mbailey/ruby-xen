require 'erb'

# The Xen config files on disk
class Xen::Config
  include Xen::Parentable
  attr_accessor :name, :kernel, :ramdisk, :memory, :root, :vbds, :vifs, :on_poweroff, :on_reboot, :on_crash, :extra

  def initialize(*args)
    options = args.extract_options!
    @name = args.first
    @kernel = options[:kernel]
    @ramdisk = options[:ramdisk]
    @memory = options[:memory]
    @root = options[:root]
    @vbds = options[:vbds]
    @vifs = options[:vifs]
    @on_poweroff = options[:on_poweroff]
    @on_reboot = options[:on_reboot]
    @on_crash = options[:on_crash]
    @extra = options[:extra]
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
    
  def config_file
    "#{Xen::XEN_DOMU_CONFIG_DIR}/#{name}.cfg"
  end
  
  def auto_file
    "#{Xen::XEN_DOMU_CONFIG_DIR}/auto/#{name}.cfg"
  end
  
  def updated_at
	  File.mtime(config_file)
	end
	
	# Set to true|false to enable|disable autostart of slice
	def auto=(value)
    filename = File.basename(config_file)
    if value == true
      File.symlink("../#{filename}", auto_file)
    else
      File.unlink(auto_file)
    end
  end
  
  # Returns true|false depending on whether slice is set to start automatically
  def auto
    File.symlink?(auto_file) && File.readlink(auto_file) == "../#{File.basename(config_file)}"
  end
  
  def self.create_from_config_file(config)
    name, kernel, ramdisk, memory, root, disk, vif, on_poweroff, on_reboot, on_crash, extra = nil
    eval(config)
    vifs = Array(vif).collect { |v| Xen::Vif.from_str(v) }
    vbds = Array(disk).collect { |d| Xen::Vbd.from_str(d) }
    new(name, :disk => disk, :kernel => kernel, :ramdisk => ramdisk, :memory => memory, :root => root, :vbds => vbds, :vifs => vifs, :on_poweroff => on_poweroff, :on_reboot => on_reboot, :on_crash => on_crash, :extra => extra)
  end
  
  def save
    template = ERB.new IO.read(Xen::TEMPLATE_DIR + '/domu.cfg.erb')
    File.open(config_file, 'w'){ |f| f.write template.result(binding) }
  end
  
end


# Virtual Network Interface
#
# http://wiki.xensource.com/xenwiki/XenNetworking
#
class Xen::Vif
  attr_accessor :ip, :mac, :bridge, :vifname
  def initialize(*args)
    options = args.extract_options!
    @ip = options[:ip] 
    @mac = options[:mac]
    @bridge = options[:bridge]
    @vifname = options[:vifname]
  end

  def self.from_str(value)
    options = value.scan(/(\w+)=([^,]+)/).inject({}){ |m, (k, v)| m[k.to_sym] = v; m }
    new(options)
  end

  def to_str
    %w(ip mac bridge vifname).collect { |key| 
      "#{key}=#{instance_variable_get('@' + key)}" if !instance_variable_get('@'+key).nil?
    }.compact.join(',')
  end 
end


# Virtual Network Interface
#
# http://wiki.xensource.com/xenwiki/XenStorage
#
# == Example 
#
#   disk        = [ 'phy:xendisks/example-disk,sda1,w', 
#                   'phy:xendisks/example-swap,sda2,w',
#                   'phy:assets/example-assets,sdb1,w' ]
class Xen::Vbd
  attr_accessor :dom0, :domu, :mode
  def initialize(dom0, domu, mode='w')
    @dom0, @domu, @mode = dom0, domu, mode
  end

  def self.from_str(value)
    dom0, domu, mode = value.split(',')
    new(dom0, domu, mode)
  end

  def to_str
    "#{dom0},#{domu},#{mode}"
  end 
end


