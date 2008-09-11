class Xen::Command
  def self.xm_list
    puts 'HEE'*100
    raw = `xm list`.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
    headers = raw.delete_at(0)
    raw.enum_with_index.map do |row, i|
      headers.inject({}) { |m, head| m[head] = row[i]; m  }
    end
  end
  
  def self.xm_info
    result = `xm info`
    result.scan(/(\S+)\s*:\s*([^\n]+)/).inject({}){ |m, (i,j)| m[i.to_sym] = j; m }
  end 
end