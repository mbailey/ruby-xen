require File.join(File.dirname(__FILE__), '..', 'helpers', 'spec_helper')

describe Xen::Command do
  include XenCommandsHelper
  before :each do
    stub_xen_commands
  end
  
  describe 'When calling xm_list' do
  
    it "should return a text string" do
      Xen::Command.xm_list.should_not be_nil
      Xen::Command.xm_list.class.should == String
    end
  end
end
