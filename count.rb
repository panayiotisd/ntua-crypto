#!/usr/bin/env ruby

# Vote Counter
# Danassis Panayiotis
# Matikas George

load 'rsaLib.rb'
require 'socket'

# Connect to Verification Server
vserver = TCPSocket.new 'localhost', 2000
# Get Verification Server's e and n
vserver.puts "read"
e = vserver.gets.to_i
n = vserver.gets.to_i
vserver.close

i = 0
sum = 0

file = File.new("votes", "r")
while (vote = file.gets)
	m = mod_pow(vote.to_i,e,n)
	if (m>=1) and (m<=10)		# check for valid message
		sum = sum + m
	end
	i = i + 1
end
file.close

avg = sum / i

puts avg