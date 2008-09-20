class Xen::Host
  attr_reader :host, :machine, :total_memory, :free_memory

  def initialize
    Xen::Command.xm_info.each do |i,j|
      instance_variable_set("@#{i}", j)
    end
  end
  
end