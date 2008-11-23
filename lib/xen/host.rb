module Xen
  class Host
    attr_reader :host, :machine, :total_memory, :nr_cpus

    def initialize(detail_hash={})
      detail_hash.each { |i,j| instance_variable_set("@#{i}", j) }
    end
    
    def self.find
      new Xen::Command.xm_info
    end
    
    def free_memory
      if f = `free -m`
        if (m = f.match /buffers\/cache.*\s+(\w+)\n/)
          m[1].to_i
        end
      end
    end
    
    def domu_memory
      Xen::Slice.find(:running).inject(0){|m, slice| m += slice.instance.memory.to_i; m}
    end
  
  end
  
end