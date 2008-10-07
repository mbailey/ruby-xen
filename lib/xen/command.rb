module Xen
  class Command
    # def self.xm_list
    #   raw = `xm list`.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
    #   headers = raw.delete_at(0)
    #   raw.map do |row|
    #     headers.enum_with_index.inject({}) { |m, (head, i)| m[head] = row[i]; m  }
    #   end
    # end
  
    # Create a tar archive of slice disk image
    def self.backup_slice(name, version, blocking=false)
      detach = blocking ? '&' : ''
      cmd = "/usr/bin/xen-archive-image #{name} #{version} #{detach}"
      system(cmd)
    end
  
    # Return the size of a logical volume in gigabytes
    def self.lv_size(vg_name, lv_name)
      cmd = "lvs --noheadings --nosuffix --options lv_size --units g #{vg_name}/#{lv_name}"
      `#{cmd}`.strip
    end
  
    # Return list of logical volumes
    def self.lv_list(vg_name)
      cmd = "lvs --noheadings --nosuffix --options vg_name,lv_name,lv_size --units g #{vg_name}"
      raw = `#{cmd}`
      raw.scan(/(\S+)\s+(\S+)\s+(\S+)/).collect{ |vg_name, lv_name, size| 
        {
        :vg => vg_name,
        :name => lv_name,
        :size => size
        }
      }
    end
  
    def self.vg_list
      cmd = "vgs --noheadings --units g --nosuffix --options vg_name,vg_size,vg_free,lv_count,max_lv"
      raw = `#{cmd}`
      raw.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/).collect{ |vg_name, vg_size, vg_free, lv_count, max_lv|
        {
        :name => vg_name,
        :size => vg_size,
        :free => vg_free,
        :lv_count => lv_count,
        :max_lv => max_lv 
        }
      }
    end
  
    def self.detailed_instance_list(name='')
      cmd = "xm list --long #{name}"
      raw_entries = `#{cmd}`.split(/\n\(domain/)
      raw_entries.collect do |entry|
        attributes = entry.scan(/\((name|domid|memory|vcpus|state|cpu_time|start_time) (.*)\)/)
        attributes.inject({}) { |m, (key, val)| m[key.to_sym] = val; m } 
      end
    end
  
    def self.start_instance(config_file)
      `xm create #{config_file}`
    end
  
    def self.shutdown_instance(name, blocking=false)
      `xm shutdown #{'-w' if blocking} #{name}`
    end
  
    # Xen::Command.create_image('memory=512', :size => '10Gb')
    # => "xm-create-image memory=512 size=10Gb"
    #
    # XXX call with a hash by default
    #
    def self.create_image(*args)
      options = args.extract_options!
      cmd = "xm-create-image #{args.concat(options.to_args).join(' ')}"
      `cmd`
    end
    
    def self.xm_info
      result = `xm info`
      result.scan(/(\S+)\s*:\s*([^\n]+)/).inject({}){ |m, (i,j)| m[i.to_sym] = j; m }
    end
  end
end