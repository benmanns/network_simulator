class NetworkSimulator::Event
  attr_accessor :time
  attr_accessor :type
  attr_accessor :entity
  attr_accessor :packet

  def initialize time, type, entity
    @time = time
    @type = type
    @entity = entity
  end
end
