#!/usr/bin/env ruby

# Voting Ender
# Danassis Panayiotis
# Matikas George

require 'socket'

mserver = TCPSocket.new 'localhost', 2001
mserver.puts "end"
mserver.close