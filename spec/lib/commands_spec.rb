require File.join(File.dirname(__FILE__), '..', 'helpers', 'spec_helper')

describe Xen::Command do
  include XenCommandsHelper
  before :each do
    stub_xen_commands
  end
  
  # XXX Xen::Command.xm_info superceded by detailed_instance_list
  #
  # describe 'When calling xm_info' do
  # 
  #   it "should return a hash of data" do
  #     Xen::Command.xm_list.should_not be_nil
  #     Xen::Command.xm_list.class.should == Hash
  #   end
  # end
  
  # XXX Xen::Command.xm_info superceded by detailed_instance_list
  #
  # describe 'When calling xm_list' do
  # 
  #   it "should return an array of hashes" do
  #     Xen::Command.xm_list.should_not be_nil
  #     Xen::Command.xm_list.class.should == Array
  #   end
  #   
  #   it "should use the first line of the response as the keys for the hashes" do
  #     results = Xen::Command.xm_list
  #     headers = File.open("#{SPEC_ROOT}/support/xm_list-servers").readline
  #     headers = headers.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
  #     results.first.keys.should = headers
  #   end
  # end
  
end
