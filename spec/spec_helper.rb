require 'spec'
require File.join(File.dirname(__FILE__), "..", "lib", "basset")

class Array

  def sort_to_s
    self.map { |item| item.to_s }.sort
  end

end

include Basset
