module Xen
  class Command
    
    class ExternalFailure < RuntimeError; end
        
    # def self.xm_list
    #   raw = `xm list`.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
    #   headers = raw.delete_at(0)
    #   raw.map do |row|
    #     headers.enum_with_index.inject({}) { |m, (head, i)| m[head] = row[i]; m  }
    #   end
    # end
    
    def self.run(cmd)
      output = []
      error = nil
      stat = Open4.popen4(cmd) do |pid, stdin, stdout, stderr|
        while line = stdout.gets
          output << line.strip
        end
        error = stderr.read.strip
      end
      # if stat.exited? # Is this needed?
        if stat.exitstatus > 0
          raise ExternalFailure, "Fatal error, `#{cmd}` returned #{stat.exitstatus} with '#{error}'"
        end
      # end
      return output
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
  
    def self.shutdown_instance(name, options={})
      `xm shutdown #{'-w' if options[:blocking]} #{name}`
    end
  
    # Xen::Command.create_image('memory=512', :size => '10Gb')
    # => "xm-create-image memory=512 size=10Gb"
    #
    # XXX call with a hash by default
    #
    def self.create_image(*args)
      options = args.extract_options!
      cmd = "xen-create-image #{args.concat(options.to_args).join(' ')}"
      puts 
      puts "Running the command:"
      puts cmd
      puts
      system(cmd)
    end
    
    def self.create_backup(*args)
      name = args.shift
      slice = Xen::Slice.find(name)
      slice.create_backup
    end
    
    def self.xm_info
      result = `/usr/sbin/xm info`
      result.scan(/(\S+)\s*:\s*([^\n]+)/).inject({}){ |m, (i,j)| m[i.to_sym] = j; m }
    end
  end
end