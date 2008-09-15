require 'deprec'

role :dev, 'bb', 'localhost'

set :application, 'ruby-xen'
set :version, '0.0.2'


task :bi do
  build
  install
end

task :build do
  `gem build #{application}.gemspec`
end

task :install, :roles => :dev do
  filename = "#{application}-#{version}.gem"
  upload "#{filename}", "/tmp/#{filename}" 
  run "#{sudo} /usr/local/bin/gem install /tmp/#{filename}"
end
  
