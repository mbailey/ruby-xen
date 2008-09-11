begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__), '..', '..', 'lib')
require 'ruby-xen'
require File.join(File.dirname(__FILE__), 'xen_commands_helper')
SPEC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
