class Xen::Command
  # def self.xm_list
  #   raw = `xm list`.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
  #   headers = raw.delete_at(0)
  #   raw.map do |row|
  #     headers.enum_with_index.inject({}) { |m, (head, i)| m[head] = row[i]; m  }
  #   end
  # end
  
  def self.detailed_instance_list(name='')
    raw_entries = `xm list --long #{name}`.split(/\n\(domain/)
    raw_entries.collect do |entry|
      attributes = entry.scan(/\((name|domid|memory|vcpus|state|cpu_time|start_time) (.*)\)/)
      attributes.inject({}) { |m, (key, val)| m[key.to_sym] = val; m } 
    end
  end
  
  def self.create(config_file)
    `xm create #{config_file}`
  end
  
  def self.shutdown(name, blocking=false)
    `xm shutdown #{'-w' if blocking} #{name}`
  end  
    
  def self.xm_info
    result = `xm info`
    result.scan(/(\S+)\s*:\s*([^\n]+)/).inject({}){ |m, (i,j)| m[i.to_sym] = j; m }
  end
end