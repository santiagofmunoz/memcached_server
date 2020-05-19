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

  def hash_clear
    HASH_TABLE.clear
  end

  # ============================
  # |    PURGE EXPIRED KEYS    |
  # ============================

  # This function searches only the request keys introduced in the command written by the user.
  # This gives the user the sense of "automatic purge of keys when they're expired" thus, optimizing
  # time and computing resources by not deleting unrequested elements.
  def purge_expired_keys(keys)
    if HASH_TABLE.empty? == false
      now = Time.now.strftime('%s')
      array_keys = Array(keys)
      array_keys.each do |key|
        string_key = String(key)
        if HASH_TABLE.has_key? string_key
          hash_element = HASH_TABLE.fetch(string_key)
          el_exp_time = hash_element.instance_variable_get(:@exp_time)
          if el_exp_time <= now
            HASH_TABLE.delete(string_key)
          end
        end
      end
    end
  end
end