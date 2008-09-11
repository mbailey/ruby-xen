class Xen::Instance
  include Xen::Parentable
  attr_reader :name, :domid, :memory, :cpu_time, :vcpus, :state, :start_time, :object_expires

  def initialize(name, options={})
    @name       = name
    @domid      = options[:domid]
    @memory     = options[:memory]
    @cpu_time   = options[:cpu_time]
    @vcpus      = options[:vcpus]
    @state      = options[:state]
    @start_time = options[:start_time]
    @object_expires = Time.now + Xen::INSTANCE_OBJECT_LIFETIME
  end

  def self.find(*args)
    options = args.extract_options!
    case args.first
    when :all       then all
    else            find_by_name(args.first)
    end
  end

  def self.all
    result = Xen::Command.xm_list
    # XXX check for failed command
    result_array = result.split("\n")
    result_array.shift
    result_array.collect do |domain|
      name, domid, memory, vcpus, state, cpu_time = domain.scan(/[^ ,]+/)
      new(name, :domid => domid, :memory => memory, :cpu_time => cpu_time)
    end
  end

  def self.find_by_name(name)
    all.detect{|domain| domain.name == name.to_s }
  end

  # XXX Rails version - we need some error checking! 
  #
  # def self.find_by_name(name, options)
  #   if result = find_every(options)
  #     result.detect{ |domain| domain.name == name }
  #   else
  #     raise RecordNotFound, "Couldn't find domain with name=#{name}"
  #   end
  # end

  def self.create(name)
    output = `xm create #{name}.cfg`
    $? == 0 ? true : false
  end

  def self.shutdown(name)
    output = `xm shutdown #{name}`
    $? == 0 ? true : false
  end

  # A convenience wrapper for <tt>find(:dom0)</tt>.</tt>.
  def self.dom0(*args)
    find_by_name(:dom0)
  end

  def uptime
    start_time ? Time.now - start_time : nil
  end

  def running?
    output = `xm list #{name}`
    $? == 0 ? true : false
  end

  def reboot
    `xm reboot #{name}`
    $? == 0 ? true : false
  end

  def destroy
  end

  def pause
  end

end
