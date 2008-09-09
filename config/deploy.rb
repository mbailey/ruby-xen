require 'deprec'

role :dev, 'bb' 

set :application, 'ruby-xen'
set :version, '0.0.1'

task :build do
  `gem build #{application}.gemspec`
end

task :install, :roles => :dev do
  filename = "#{application}-#{version}.gem"
  upload "#{filename}", "/tmp/#{filename}" 
  run "#{sudo} gem install /tmp/#{filename}"
end
  