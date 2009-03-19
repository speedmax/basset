# This file contains extensions to built in Ruby classes.

require 'rubygems'
require 'stemmer'

# Extensions to the array class.
class Array
  # Returns a new array that contains everything except the first element of this one. (just like in lisp)
  def rest
    return self if empty?
    self.slice(1, size)
  end
  
  # Returns the second item in the array
  def second
    self[1]
  end
  
  # Returns a random item from the array
  def pick_random
    self[rand(self.size)]
  end
  
  # Returns a randomized array
  def randomize
    self.sort_by { rand }
  end
  
  def sum
    inject(0) { |sum, val| sum + val }
  end
  
  # Randomizes array in place
  def randomize!
    self.replace(self.randomize)
  end
end

class Float
  def to_s_decimal_places(decimal_places)
    pattern = "[0-9]*\."
    decimal_places.times { pattern << "[0-9]"}
    return self.to_s.match(pattern)[0]
  end
end

class Symbol
  unless public_method_defined? :to_proc
    def to_proc
      Proc.new { |*args| args.shift.__send__(self, *args) }
    end
  end
end

# Extensions to the string class.
# We're just including the stemmable module into string. This adds the .stem method.
class String
  include Stemmable
end

module Math
  
  def variance(population)
    n = 0
    mean = 0.0
    s = 0.0
    population.each { |x|
      n = n + 1
      delta = x - mean
      mean = mean + (delta / n)
      s = s + delta * (x - mean)
    }
    # if you want to calculate std deviation
    # of a sample change this to "s / (n-1)"
    return s / n
  end
  
  # calculate the standard deviation of a population
  # accepts: an array, the population
  # returns: the standard deviation
  def stddev(population)
    sqrt(variance(population))
  end
  

  def avg(pop)
    total = pop.inject(0) { |sum, n| sum + n }
    total.to_f / pop.count.to_f
  end
  
  module_function :variance, :avg, :stddev
  
end