require File.join(File.dirname(__FILE__), '..', 'helpers', 'spec_helper')

describe Xen::Slice do
  include XenCommandsHelper
  before :each do
    stub_xen_commands
  end
  
  describe 'When calling Slice.find :all' do
  
    it 'should return only running instances'
    
    it 'should return all running instances'
    
    it 'should return [] if there are no running instances' do
      Xen::Command.stub!(:xm_info).and_return(File.read("#{SPEC_ROOT}/support/xm_list-no_servers"))
      Xen::Slice.find(:all).should be_empty
    end
    
  end
  
  describe ''
  
end
    