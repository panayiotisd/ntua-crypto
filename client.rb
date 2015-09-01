#!/usr/bin/env ruby

# Client for anonymous evaluation
# Danassis Panayiotis
# Matikas George

load 'rsaLib.rb'
require 'socket'

#Read username and password
puts "Username: "
username = gets
puts "Password: "
password = gets

#Read course score
begin
	puts "Evaluate Cryptography and Complexity course (1-10): "
	vote = gets.to_i
end while (vote < 1 or vote > 10)

# Connect to Verification Server
vserver = TCPSocket.new 'localhost', 2000
# Get Verification Server's e and n
vserver.puts "read"

e = vserver.gets.to_i
n = vserver.gets.to_i
vserver.close

begin
	r = create_random_bignum(128)
end while (r.gcd(n) != 1)
masked_vote = (vote * (r**e))%n

# Connect to Verification Server
vserver = TCPSocket.new 'localhost', 2000
# Verification Server: Sign request 
vserver.puts "sign"
vserver.puts username
vserver.puts password
vserver.puts masked_vote
signed_masked_vote = vserver.gets.to_i
vserver.close
if signed_masked_vote == -1
  abort("Wrong username/password!")
end
if signed_masked_vote == -2
  abort("You have already voted!")
end

signed_vote = (signed_masked_vote * invert(r,n))%n

# Connect to Mix Server 1
mserver = TCPSocket.new 'localhost', 2001
# Get Mix Server's e and n
mserver.puts "read"
e1 = mserver.gets.to_i
n1 = mserver.gets.to_i
mserver.close

# Connect to Mix Server 2
mserver = TCPSocket.new 'localhost', 2002
# Get Mix Server's e and n
mserver.puts "read"
e2 = mserver.gets.to_i
n2 = mserver.gets.to_i
mserver.close

# Encrypt vote
enc_signed_vote = mod_pow(mod_pow(signed_vote, e2, n2), e1, n1)

# Connect to Mix Server 1
mserver = TCPSocket.new 'localhost', 2001
# Place vote
mserver.puts "vote"
mserver.puts enc_signed_vote
mserver.close