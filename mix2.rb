#!/usr/bin/env ruby

# MixServer 2
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

server = TCPServer.new 2002

votes = Array.new

loop do
	client = server.accept
	
	proc = client.gets
	
	if proc == "read\n"
		client.puts e
		client.puts n
	end
	
	if proc == "mix\n"
		k = client.gets.to_i
		
		i = 0
		while i < k
		  v = client.gets.to_i
		  v = mod_pow(v,d,n)
		  votes.push(v)
		  i = i + 1
		end
		
		votes.shuffle(random: Random.new(1))
		
		file = File.new("votes", "w")
		i = 0
		while i < k
		  file.puts(votes[i])
		  i = i + 1
		end
		file.close
	end
	
	if proc == "end\n"
		client.close
		break
	end
	
	client.close
end