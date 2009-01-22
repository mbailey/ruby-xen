module Xen
  class Backup
    include Xen::Parentable
  
    attr_accessor :name, :version
  
    def self.create(*args)
      options = args.extract_options!
      name = args.first
      
      # options = {}
      # name = 'foo' # XXX replace with real value
      version = options[:version] || Time.now.strftime('%Y%m%d')
      backup_dir = options[:backup_dir] || Xen::BACKUP_DIR
      backup_file_ext = options[:backup_file_ext] || Xen::BACKUP_FILE_EXT
      archive_name="#{name}-#{version}#{backup_file_ext}"
            
      slice = Xen::Slice.find(name) # XXX test for failure
      if slice.running?
        slice.stop
        sleep 10
        restart_slice = true
      end

      temp_mount = `mktemp -d -p /mnt #{name}-XXXXX`.chomp # XXX test for failure
      `mount #{slice.root_disk.path} #{temp_mount}` # XXX test for failure

      # Creating archive at backup_dir/archive_name ...
      excludes_file = File.join(File.dirname(__FILE__),'..','templates','exclude_from_backups')
      `tar --create --exclude-from=#{excludes_file} --directory #{temp_mount} --file #{backup_dir}/#{archive_name} .`

      # XXX test for failure
      
      # Unmounting image
      `umount #{temp_mount}`
      Dir.delete(temp_mount)

      # Creating symlink from new backup to filename without version number
      last_backup = "#{backup_dir}/#{name}#{backup_file_ext}"
      File.delete(last_backup) if File.symlink?(last_backup)
      `ln -sf #{backup_dir}/#{archive_name} #{last_backup}`
      
      slice.start if restart_slice == true
      
      new(:name => name, :version => version)
    end

    def initialize(*args)
      options = args.extract_options!
      @name = options[:name]
      @version = options[:version]
    end
  
    def self.find(*args)
      # return all
      slice = args.first
      Dir.glob("#{Xen::BACKUP_DIR}/*-*#{Xen::BACKUP_FILE_EXT}").collect { |file|
        if match = File.basename(file, Xen::BACKUP_FILE_EXT).match(/(#{ slice || '.*' })-(.*)/)
          new(:name => match[1], :version => match[2])
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
end