require 'optparse'

require 'network_simulator/event'

class NetworkSimulator::Main
  class << self
    def run!
      begin
        opt = ARGV.getopts 'bc:l:p:d:'
      rescue OptionParser::InvalidOption => e
        puts "Usage: #{$0} [-c corruption_percentage] [-l loss_percentage] [-p packets_to_send] [-d delay_between_packets] [-b]"
        exit
      end

      $events = []
      $bidirectional = opt['b'] || false
      $corruption = (opt['c'] || 0.0).to_f
      $loss = (opt['l'] || 0.0).to_f
      packets_to_send = (opt['p'] || 10).to_i
      $delay = (opt['d'] || 25).to_i
      $current_time = 0

      puts
      puts
      puts 'Welcome to the CSCI 355 Network Simulator.'
      puts "We will run the simulator with #{packets_to_send} packets (with #{$delay} seconds on average between packets), a corruption percentage of #{$corruption}, a loss percentage of #{$loss}"
      puts
      puts
      puts 'This will be run in BIDIRECTIONAL mode' if $bidirectional

      a_init if defined? :a_init
      b_init if defined? :b_init

      time_of_packet = 0
      packets_to_send.times do
        $events << NetworkSimulator::Event.new(time_of_packet, :send_data, :a)
        time_of_packet += $delay
      end

      if $bidirectional
        time_of_packet = 10
        packets_to_send.times do
          $events << NetworkSimulator::Event.new(time_of_packet, :send_data, :b)
          time_of_packet += $delay
        end
      end

      data_value = 0
      until $events.sort!.empty? # TODO: Replace with a real Priority Queue.
        event = $events.shift
        $current_time = event.time
        puts "Processing event => #{event} at time #{$current_time}"
        case event.type
        when :send_data
          message = Message.new
          message.data = (data_value + 97).chr * 20
          data_value = (data_value + 1) % 26
          if event.entity == :a
            a_rdt_send message if defined? :a_rdt_send
          else
            b_rdt_send message if defined? :b_rdt_send
          end
        when :timeout
          if event.entity == :a
            a_timeout if defined? :a_timeout
          else
            b_timeout if defined? :b_timeout
          end
        when :receive_data
          packet = event.packet
          if event.entity == :a
            a_udt_recv packet if defined? :a_udt_recv
          else
            b_udt_recv packet if defined? :b_udt_recv
          end
        else
          puts 'Unknown event type!!  What did you do?!?!?!?'
        end
      end
      puts
      puts
      puts 'Thank you for using the CSCI 355 Network Simulator.  Have a nice day!'
      puts
    end
  end
end
