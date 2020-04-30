class Memcached

  attr_accessor :key

  def create_hash
    @@hash_table = Hash.new
  end

end