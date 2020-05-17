require 'date'

class Memcached

  # Declaration of hash
  HASH_TABLE = Hash.new

  def initialize(**params)
    @flag = params[:flag]
    @exp_time = params[:exp_time]
    @size = params[:size]
    @cas_value = params[:cas_value]
    @value = params[:value]
  end

  def hash_store(key, object)
    HASH_TABLE.store(key, object)
  end

  def hash_has_key(key)
    HASH_TABLE.key?(key)
  end

  def hash_fetch(key)
    HASH_TABLE.fetch(key)
  end

  def hash_key(key)
    HASH_TABLE[key]
  end

  def hash_empty
    HASH_TABLE.empty?
  end

  # ============================
  # |    PURGE EXPIRED KEYS    |
  # ============================

  def purge_expired_keys
    now = Time.now.strftime('%s')
    HASH_TABLE.delete_if{|k, v| v.instance_variable_get(:@exp_time) < now}
  end
end