class Xen::Backup
  include Xen::Parentable
  
  attr_accessor :name, :version
  
  def self.create(*args)
    options = args.extract_options!
    name = args.first
    version = options[:version] || Time.now.strftime('%Y%m%d')
    
    Xen::Command.backup_slice(name, version, false)
    new(name, version)
  end
      
  def initialize(*args)
    options = args.extract_options!
    @name = args.first
    @version = options[:version]
  end
  
  def self.find(*args)
    # return all
    slice = args.first
    Dir.glob("#{Xen::BACKUP_DIR}/*-*#{Xen::BACKUP_FILE_EXT}").collect { |file|
      if match = File.basename(file, Xen::BACKUP_FILE_EXT).match(/(#{ slice || '.*' })-(.*)/)
        new(match[1], :version => match[2])
      end
    }.compact
  end
    
  def filename
    "#{@name}-#{@version}#{Xen::BACKUP_FILE_EXT}"
  end
  
  def fullpath
    File.join(Xen::BACKUP_DIR, filename)
  end
  
  def size
    File.size(fullpath)
  end

end