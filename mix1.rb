#!/usr/bin/env ruby

# MixServer 1
# Danassis Panayiotis
# Matikas George

load 'rsaLib.rb'
require 'socket'

# Make two big primes: p and q
p = create_random_prime(512)
q = create_random_prime(512)

# Make n (the public key) now
n = p*q

# Public exponent
e = 0x10001

# Private exponent
d = get_d(p,q,e)

server = TCPServer.new 2001

votes = Array.new

loop do
	client = server.accept
	
	proc = client.gets
	
	if proc == "read\n"
		client.puts e
		client.puts n
	end
	
	if proc == "vote\n"
		c = client.gets.to_i
		vote = mod_pow(c,d,n)
		votes.push(vote)
	end
	
	if proc == "end\n"
		client.close
		break
	end
	
	client.close
end

votes.shuffle(random: Random.new(1))

s = TCPSocket.new 'localhost', 2002

s.puts "mix"
s.puts votes.length

i = 0
while i < votes.length
  s.puts votes[i]
  i = i + 1
end

s.close