require 'erb'

# The Xen config files on disk
class Xen::Config
  include Xen::Parentable
  attr_accessor :name, :kernel, :ramdisk, :memory, :root, :disk, :vif, :on_poweroff, :on_reboot, :on_crash, :extra

  def initialize(*args)
    options = args.extract_options!
    @name = args.first
    @kernel = options[:kernel]
    @ramdisk = options[:ramdisk]
    @memory = options[:memory]
    @root = options[:root]
    @disk = options[:disk]
    @vif = options[:vif]
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
  
  def self.create_from_config_file(config)
    name, kernel, ramdisk, memory, root, disk, vif, on_poweroff, on_reboot, on_crash, extra = nil
    eval(config)
    new(name, :disk => disk, :kernel => kernel, :ramdisk => ramdisk, :memory => memory, :root => root, :disk => disk, :vif => vif, :on_poweroff => on_poweroff, :on_reboot => on_reboot, :on_crash => on_crash, :extra => extra)
  end
  
  def save
    template = ERB.new IO.read(Xen::TEMPLATE_DIR + '/domu.cfg.erb')
    File.open(config_file, 'w'){ |f| f.write template.result(binding) }
  end
  
end