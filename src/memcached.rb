require 'date'

class Memcached

  attr_accessor :key

  def initialize
    @hash_table = Hash.new
  end

end