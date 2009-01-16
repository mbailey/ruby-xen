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
  
  
  # XXX Move this somewhere else!
  
  # Network Bridge Script looks like this.
  #
  # #!/bin/sh
  # /etc/xen/scripts/network-bridge $1 netdev=eth0 bridge=xenbr0 vifnum=0 antispoof=no
  # /etc/xen/scripts/network-bridge $1 netdev=eth1 bridge=xenbr1 vifnum=1 antispoof=no
  
  class Bridges
    NETWORK_BRIDGE_WRAPPER = '/etc/xen/scripts/network-bridge-wrapper'
    
    def self.find
      f = File.readlines(NETWORK_BRIDGE_WRAPPER).collect { |line|
        if (m = line.match /netdev=(.*) bridge=(.*) vifnum=(.*) antispoof=(.*)/)
          Xen::Bridge.new :netdev => m[1], :bridge => m[2], :vifnum => m[3], :antispoof => m[4]
        end
      }.compact
    end
    
    def self.save
    end
    
  end
  
  class Bridge
    attr_accessor :netdev, :bridge, :vifnum, :antispoof
    
    def initialize(*args)
      options = args.extract_options!
      @netdev = options[:netdev]
      @bridge = options[:bridge]
      @vifnum = options[:vifnum]
      @antispoof = options[:antispoof]
    end
  end
  
end