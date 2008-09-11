class Xen::Image
  include Xen::Parentable
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def self.find(name)
    new name
  end
end
