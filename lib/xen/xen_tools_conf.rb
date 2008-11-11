module Xen
  # puts Xen::XenToolsConf.load.to_hash.inspect

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
          instance_variable_set("@#{key.strip.underscorize}", val.strip) 
        }
      }
    end

    def to_hash
      self.instance_variables.inject({}) { |m, variable_name| 
        m[variable_name.sub('@','').ununderscorize] = instance_variable_get(variable_name); m 
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
