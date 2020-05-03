class Memcached

  attr_accessor :key

  # This method must be called ONCE and ONLY when the server is started
  # otherwise the table will be regenerated and emptied.
  def create_hash
    @@hash_table = Hash.new
  end

end