class Xen::Command
  def self.xm_list
    raw = `xm list`.scan(/(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/)
    headers = raw.delete_at(0)
    raw.map do |row|
      headers.enum_with_index.inject({}) { |m, (head, i)| m[head] = row[i]; m  }
    end
  end
  
  def self.xm_info
    result = `xm info`
    result.scan(/(\S+)\s*:\s*([^\n]+)/).inject({}){ |m, (i,j)| m[i.to_sym] = j; m }
  end
end