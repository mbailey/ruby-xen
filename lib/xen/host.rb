class Xen::Host
  attr_reader :host, :machine, :total_memory, :free_memory

  def initialize
    result = Xen:Command.xm_info
    result.scan(/(\S+)\s*:\s*([^\n]+)/).each do |i,j| 
      instance_variable_set("@#{i}", j)
    end
  end
end