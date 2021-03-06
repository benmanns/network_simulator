module NetworkSimulator
  require 'network_simulator/event'
  require 'network_simulator/main'
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
    packet = packet.clone

    corruption_chance = rand
    if corruption_chance < $corruption
      puts '        Packet being corrupted'
      if corruption_chance < 0.75
        packet.payload[0] = packet.payload[0].next if packet.payload
      elsif corruption_chance < 0.90
        packet.seq += 1 if packet.seq
      else
        packet.ack += 1 if packet.ack
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

  def start_timer timeout, entity
    $events << NetworkSimulator::Event.new($current_time + timeout, :timeout, entity)
  end
  module_function :start_timer

  def a_start_timer timeout
    start_timer timeout, :a
  end
  module_function :a_start_timer

  def b_start_timer timeout
    start_timer timeout, :b
  end
  module_function :b_start_timer

  def a_udt_send packet
    generate_send packet, :b
  end
  module_function :a_udt_send

  def b_udt_send packet
    generate_send packet, :a
  end
  module_function :b_udt_send

  def a_stop_timer
    $a_timer_disabled += 1
  end
  module_function :a_stop_timer

  def b_stop_timer
    $b_timer_disabled += 1
  end
  module_function :b_stop_timer
end
