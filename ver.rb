#!/usr/bin/env ruby

# Verification Server
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

voted = File.new("voted", "w")
voted.close

server = TCPServer.new 2000 # Server bound to port 2000

loop do
	client = server.accept    # Wait for a client to connect
	
	proc = client.gets
	
	if proc == "read\n"
		client.puts e
		client.puts n
	end
	
	if proc == "sign\n"
		username = client.gets
		password = client.gets
		m = client.gets.to_i
		
		f = 0
		file = File.new("users", "r")
		while (user = file.gets)
			pass = file.gets
			if (user == username) and (pass == password)
				f = 1
				break
			end
		end
		file.close
		
		if f == 1
			voted = File.new("voted", "r")
			f = 0
			while (user = voted.gets)
				if (user == username)
					f = 1
					break
				end
			end
			voted.close
			if f == 0
				voted = File.new("voted", "a")
				voted.puts username
				voted.close
				s = mod_pow(m,d,n)
			else
				s = -2
			end
		else
			s = -1
		end
		
		client.puts s;
	end
	
	if proc == "end\n"
		client.close
		break
	end
	
	client.close
end