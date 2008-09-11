class Xen::Command
  def self.xm_list
    `xm list`
  end
  def self.xm_info
    `xm info`
  end 
end
