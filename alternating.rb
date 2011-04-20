#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'network_simulator'

include NetworkSimulator

##
## Students will have be able to use the following functions:
## a_udt_send packet
## b_udt_send packet
## a_start_timer timeout
## b_start_timer timeout
## a_to_layer_five message
## b_to_layer_five message
## a_stop_timer
## b_stop_timer
##

##
## Students must implement the following six functions:
## (They are currently implemented for unreliable data transfer).
##

def package message, entity
  packet = NetworkSimulator::Packet.new
  packet.payload = message.data
  packet.seq = entity == :a ? @a_send_sequence : @b_send_sequence
  packet.checksum = (packet.payload.hash + packet.seq.hash + packet.ack.hash) & 0xFFFFFFFF
  packet
end

def a_init
  @a_send_sequence = 0
  @a_receive_sequence = 0
  @a_messages = []
  @a_sent = 0
end

def b_init
  @b_send_sequence = 0
  @b_receive_sequence = 0
  @b_messages = []
  @b_sent = 0
end

def a_rdt_send message
  @a_messages << message
  if @a_sent >= @a_messages.length - 1
    message = @a_messages[@a_sent]
    packet = package message, :a
    a_udt_send packet
    a_start_timer $delay + 10
  end
end

def a_timeout
  message = @a_messages[@a_sent]
  packet = package message, :a
  a_udt_send packet
  a_start_timer $delay + 10
end

def a_udt_recv packet
  unless packet.checksum != (packet.payload.hash + packet.seq.hash + packet.ack.hash) & 0xFFFFFFFF
    if packet.payload
      if packet.seq == @a_receive_sequence
        @a_receive_sequence ^= 1
        message = NetworkSimulator::Message.new
        message.data = packet.payload
        a_to_layer_five message
      end
      ack = NetworkSimulator::Packet.new
      ack.ack = packet.seq
      ack.checksum = (ack.payload.hash + ack.seq.hash + ack.ack.hash) & 0xFFFFFFFF
      a_udt_send ack
    elsif packet.ack == @a_send_sequence
      a_stop_timer
      @a_send_sequence ^= 1
      if message = @a_messages[@a_sent + 1]
        @a_sent += 1
        packet = package message, :a
        puts "## Ack Sending: #{packet.payload}"
        a_udt_send packet
        a_start_timer $delay + 10
      end
    end
  end
end

def b_udt_recv packet
  unless packet.checksum != (packet.payload.hash + packet.seq.hash + packet.ack.hash) & 0xFFFFFFFF
    if packet.payload
      if packet.seq == @b_receive_sequence
        @b_receive_sequence ^= 1
        message = NetworkSimulator::Message.new
        message.data = packet.payload
        b_to_layer_five message
      end
      ack = NetworkSimulator::Packet.new
      ack.ack = packet.seq
      ack.checksum = (ack.payload.hash + ack.seq.hash + ack.ack.hash) & 0xFFFFFFFF
      b_udt_send ack
    elsif packet.ack == @b_send_sequence
      b_stop_timer
      @b_send_sequence ^= 1
      if message = @b_messages[@b_sent + 1]
        @b_sent += 1
        packet = package message, :b
        puts "## Ack Sending: #{packet.payload}"
        b_udt_send packet
        b_start_timer $delay + 10
      end
    end
  end
end

##
## Students may implement the following two functions for extra credit.
## (They are currently implemented for unreliable data transfer).
##

def b_rdt_send message
  @b_messages << message
  if @b_sent >= @b_messages.length - 1
    message = @b_messages[@b_sent]
    packet = package message, :b
    b_udt_send packet
    b_start_timer $delay + 10
  end
end

def b_timeout
  message = @b_messages[@b_sent]
  packet = package message, :b
  b_udt_send packet
  b_start_timer $delay + 10
end

NetworkSimulator::Main.run!
