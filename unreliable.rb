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

def a_init
end

def b_init
end

def a_rdt_send message
  puts 'A Sending Data Unreliably...'
  packet = NetworkSimulator::Packet.new
  packet.payload = message.data
  a_udt_send packet
end

def a_timeout
end

def a_udt_recv packet
  message = NetworkSimulator::Message.new
  message.data = packet.payload
  a_to_layer_five message
end

def b_udt_recv packet
  message = NetworkSimulator::Message.new
  message.data = packet.payload
  b_to_layer_five message
end

##
## Students may implement the following two functions for extra credit.
## (They are currently implemented for unreliable data transfer).
##

def b_rdt_send message
  puts 'B Sending Data Unreliably...'
  packet = Packet.new
  packet.payload = message.data
  b_udt_send packet
end

def b_timeout
end

NetworkSimulator::Main.run!
