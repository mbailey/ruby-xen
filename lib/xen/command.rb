class Xen::Command
  # def self.xm_list
  #   raw = `xm list`.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
  #   headers = raw.delete_at(0)
  #   raw.map do |row|
  #     headers.enum_with_index.inject({}) { |m, (head, i)| m[head] = row[i]; m  }
  #   end
  # end
  
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