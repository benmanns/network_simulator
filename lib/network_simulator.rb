module NetworkSimulator
  require 'network_simulator/event'
  require 'network_simulator/message'
  require 'network_simulator/packet'

  def generate_send packet, entity
    loss_chance = rand
    if loss_chance < $loss
      puts '        Packet being lost'
      return
    end

    random_modification = rand(10) - 4
    time = $current_time + $delay + random_modification
    puts "next time is #{$current_time + $delay} and the modification to the time is #{random_modification}"
    event = NetworkSimulator::Event.new time, :receive_data, entity

    corruption_chance = rand
    if corruption_chance < $corruption
      puts '        Packet being corrupted'
      if corruption_chance < 0.75
        event.packet.payload[0] = event.packet.payload[0].next if event.packet.payload
      elsif corruption_chance < 0.90
        event.packet.seq += 1 if event.packet.seq
      else
        event.packet.ack += 1 if event.packet.ack
      end
    end

    event.packet = packet
    puts "Scheduled event => #{event}"
    $events << event
  end
  module_function :generate_send

  def a_to_layer_five message
    puts "A successfully received this message: #{message.data}"
  end
  module_function :a_to_layer_five

  def b_to_layer_five message
    puts "B successfully received this message: #{message.data}"
  end
  module_function :b_to_layer_five
end
