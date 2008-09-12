class Xen::Command
  def self.xm_list
    `xm list`
  end
  
  def self.detailed_instance_list(name='')
    raw_entries = `xm list --long #{name}`.split(/\n\(domain/)
    raw_entries.collect do |entry|
      attributes = entry.scan(/\((name|domid|vcpus|state|memory|start_time|cpu_time) (.*)\)/)
      attributes.inject({}) { |m, (key, val)| m[key.to_sym] = val; m } 
    end
  end
  
  def self.xm_info
    `xm info`
  end 
end
