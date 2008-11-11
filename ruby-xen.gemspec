Gem::Specification.new do |s|
  s.name     = "ruby-xen"
  s.version  = "0.0.3"
  s.date     = "2008-09-21"
  s.summary  = "Ruby library for managing Xen virtual hosts"
  s.email    = "mike@bailey.net.au"
  s.homepage = "http://github.com/mbailey/ruby-xen"
  s.description = "ruby-xen allows you to manage Xen virtual servers via Ruby. It currently 
  wraps the command line tools provided by Xen (xm) as well as Steve Kemps 
  excellent Xen-tools (http://www.xen-tools.org/software/xen-tools/)."
  s.has_rdoc = true
  s.authors  = ["Mike Bailey", "Nick Marfleet"]
  s.files    = %w(
    History.txt
    Manifest.txt
    README.rdoc
    Rakefile
    bin/ruby-xen
    lib/ruby-xen.rb
    test/test_ruby-xen.rb
    lib/xen/backup.rb
    lib/xen/command.rb
    lib/xen/config_file.rb
    lib/xen/host.rb
    lib/xen/instance.rb
    lib/xen/lvm.rb
    lib/xen/slice.rb
    lib/xen/xen_tools_conf.rb
    lib/templates/domu.cfg.erb
    lib/templates/xen-tools.conf.erb
  )
  s.require_paths = ['lib']
  # s.test_files = ["test/test_actor.rb"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.add_dependency("activesupport")
  s.add_dependency("open4")
end
