require 'date'

class Memcached

  # Declaration of hash
  Hash_table = Hash.new

  def initialize(**params)
    @flag = params[:flag]
    @exp_time = params[:exp_time]
    @size = params[:size]
    @cas_value = params[:cas_value]
    @value = params[:value]
  end

  # TODO: DELETE THIS. It's just a debug tool, not required in the release version.
  def show_all_hash
    Hash_table
  end

  def hash_store(key, object)
    Hash_table.store(key, object)
  end

  def hash_has_key(key)
    Hash_table.key?(key)
  end

  def hash_fetch(key)
    Hash_table.fetch(key)
  end

  def hash_key(key)
    Hash_table[key]
  end

  def hash_empty
    Hash_table.empty?
  end

  # ============================
  # |    PURGE EXPIRED KEYS    |
  # ============================

  def search_expired_keys
    if Hash_table.empty? == false
      count = 0
      now = Time.now.strftime('%s')
      log_date = Time.now.strftime('%d/%m/%Y %H:%M:%S')
      Hash_table.each do |key, value|
        exp_time = value[1]
        if exp_time != 0
          if exp_time < now
            Hash_table.delete(key)
            count = count+1
          end
        end
      end
      puts "[#{log_date}] #{count} expired keys have been purged"
    end
  end
end