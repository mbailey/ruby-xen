module XenCommandsHelper

 def stub_xen_commands
   Xen::Command.stub!(:xm_info).and_return(File.read("#{SPEC_ROOT}/support/xm_info"))
   Xen::Command.stub!(:xm_list).and_return(File.read("#{SPEC_ROOT}/support/xm_list-servers"))
   # Xen::XEN_DOMU_CONFIG_DIR = "#{SPEC_ROOT}/support"
 end

end