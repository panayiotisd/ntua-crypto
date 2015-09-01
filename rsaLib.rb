# Simple implementation of RSA using Ruby

# Primality test
# http://en.wikipedia.org/wiki/Miller-Rabin_primality_test
class Integer # From http://snippets.dzone.com/posts/show/4636
   def prime?
     n = self.abs()
     return true if n == 2
     return false if n == 1 || n & 1 == 0
     # cf. http://betterexplained.com/articles/another-look-at-prime-numbers/ and
     # http://everything2.com/index.pl?node_id=1176369
     return false if n > 3 && n % 6 != 1 && n % 6 != 5 # added
     d = n-1
     d >>= 1 while d & 1 == 0
     20.times do # 20 = k from above
       a = rand(n-2) + 1
       t = d
       y = mod_pow(a,t,n) # implemented below
       while t != n-1 && y != 1 && y != n-1
         y = (y * y) % n
         t <<= 1
       end
       return false if y != n-1 && t & 1 == 0
     end
     return true
   end
end

# Calculate a modular exponentiation eg: b^p mod m
# http://en.wikipedia.org/wiki/Modular_exponentiation
def mod_pow(base, power, mod)
 result = 1
 while power > 0
   result = (result * base) % mod if power & 1 == 1
   base = (base * base) % mod
   power >>= 1;
 end
 result
end

# Make a random bignum of size bits, with the highest two and low bit set
# http://www.di-mgt.com.au/rsa_alg.html#note1
def create_random_bignum(bits)
  middle = (1..bits-3).map{rand()>0.5 ? '1':'0'}.join
  str = "11" + middle + "1"
  str.to_i(2)
end

# Create random numbers until it finds a prime
def create_random_prime(bits)
  while true
    val = create_random_bignum(bits)
    return val if val.prime?
  end
end

# Do the extended euclidean algorithm: ax + by = gcd(a,b)
# http://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Recursive_method_2
def extended_gcd(a, b)
  return [0,1] if a % b == 0
  x,y = extended_gcd(b, a % b)
  [y, x-y*(a / b)]
end

# Get the modular multiplicative inverse of a modulo b: a^-1 equiv x (mod m)
# http://en.wikipedia.org/wiki/Modular_multiplicative_inverse
def get_d(p,q,e)
  # From wiki: The extended Euclidean algorithm is particularly useful when a and b are coprime,
  # since x is the modular multiplicative inverse of a modulo b.
  phi = (p-1)*(q-1)
  x,y = extended_gcd(e,phi)
  x += phi if x<0 # Have to add the modulus if it returns negative, to get the modular multiplicative inverse
  x
end

# Convert a string into a big number
def str_to_bignum(s)
  n = 0
  s.each_byte{|b|n=n*256+b}
  n
end

# Convert a bignum to a string
def bignum_to_str(n)
  s=""
  while n>0
    s = (n&0xff).chr + s
    n >>= 8
  end
  s
end

# Returns an array of the form `[gcd(x, y), a, b]`, where
# `ax + by = gcd(x, y)`.
#
# @param [Integer] x
# @param [Integer] y
# @return [Array<Integer>]
def gcdext(x, y)
	if x < 0
		g, a, b = gcdext(-x, y)
		return [g, -a, b]
	end
	if y < 0
		g, a, b = gcdext(x, -y)
		return [g, a, -b]
	end
	r0, r1 = x, y
	a0 = b1 = 1
	a1 = b0 = 0
	until r1.zero?
		q = r0 / r1
		r0, r1 = r1, r0 - q*r1
		a0, a1 = a1, a0 - q*a1
		b0, b1 = b1, b0 - q*b1
	end
	[r0, a0, b0]
end

# Returns the inverse of `num` modulo `mod`.
#
# @param [Integer] num the number
# @param [Integer] mod the modulus
# @return [Integer]
# @raise ZeroDivisionError if the inverse of `base` does not exist
def invert(num, mod)
	g, a, b = gcdext(num, mod)
	unless g == 1
		raise ZeroDivisionError.new("#{num} has no inverse modulo #{mod}")
	end
	a % mod
end