class NetworkSimulator::Packet
  attr_accessor :seq
  attr_accessor :ack
  attr_accessor :nak
  attr_accessor :checksum
  attr_accessor :payload

  def clone
    new = super
    new.payload = payload.clone if payload.is_a? String
    new
  end
end
