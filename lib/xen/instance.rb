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
    @start_time = Time.at(options[:start_time].to_f) if options[:start_time]
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
    Xen::Command.detailed_instance_list.collect do |instance|
      new(name, instance)
    end
  end

  def self.find_by_name(name)
    Xen::Command.detailed_instance_list(name).each do |instance|
      return new(name, instance)
    end
    return false
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
    output = Xen::Command.create(name.to_s + Xen::CONFIG_FILE_EXTENSION)
    $? == 0 ? true : false
  end

  def self.shutdown(name)
    output = Xen::Command.shutdown(name)
    $? == 0 ? true : false
  end

  # A convenience wrapper for <tt>find(:dom0)</tt>.</tt>.
  def self.dom0(*args)
    find_by_name(:dom0)
  end

  def uptime
    start_time ? Time.now - start_time : nil
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
