class Memcached

  attr_accessor :key, :flag, :exp_time, :size

  def createHashTable
    @hash_table = Hash.new
  end

  # def set
  #   @key = key
  #   @flag = flag
  #   @exp_time = exp_time
  #   @size = size
  #   # @hash_table.create()
  # end
end