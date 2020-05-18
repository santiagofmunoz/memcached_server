require 'date'
require_relative 'memcached'

class Storage

  attr_accessor :stored_cas_value

  OK = 'OK'
  ERROR = 'ERROR'
  CE_BCLF = 'CLIENT_ERROR bad command line format'
  CE_BDC = 'CLIENT_ERROR bad data chunk'
  STORED = 'STORED'
  NOT_STORED = 'NOT_STORED'
  EXISTS = 'EXISTS'
  NOT_FOUND = 'NOT_FOUND'
  MAX_EXP_TIME_SECONDS = 2592000 # Number of seconds in 30 days.

  def initialize_stored_cas_value
    @stored_cas_value = 0
  end

  def check_data_integrity(key, flag, exp_time, size, cas_value, value)
    if key.nil? == true || flag.nil? == true || exp_time.nil? == true || size.nil? == true
      ERROR
    else
      begin
        String(key)
        int_flag = Integer(flag)
        Integer(exp_time)
        int_size = Integer(size)
        string_value = String(value)
        value_length = string_value.length
        if cas_value.nil? == false
          Integer(cas_value)
        end
        if int_flag < 0 || int_size < 0
          CE_BCLF
        elsif value_length > int_size
          CE_BDC
        else
          mc = Memcached.new
          mc.purge_expired_keys(key)
          OK
        end
      rescue ArgumentError => e
        CE_BCLF
      end
    end
  end

  def set(key, flag, exp_time, size, value, no_reply)
    # Transformation of received data to desired type
    string_key = String(key)
    int_flag = Integer(flag)
    int_exp_time = Integer(exp_time)
    int_size = Integer(size)
    string_value = String(value)
    new_cas_value = @stored_cas_value+1

    # Check if data has expiration time
    # The expiration time is standardised to UNIX time
    if int_exp_time == 0
      unix_expiration_time = 0;
    else
      if int_exp_time > MAX_EXP_TIME_SECONDS
        unix_expiration_time = int_exp_time
      else
        expiration_time = Time.now + int_exp_time
        unix_expiration_time = expiration_time.strftime("%s")
      end
    end
    mc_obj = Memcached.new(flag: int_flag, exp_time: unix_expiration_time, size: int_size, cas_value: new_cas_value, value: string_value)
    mc_obj.hash_store(string_key, mc_obj)
    @stored_cas_value = new_cas_value
    if no_reply == false
        STORED
    end
  end

  def add(key, flag, exp_time, size, value, no_reply)
    mc = Memcached.new
    # Transformation of received data to desired type
    string_key = String(key)
    key_exists = mc.hash_has_key(string_key)
    if key_exists == true
      if no_reply == false
        NOT_STORED
      end
    else
      set(key, flag, exp_time, size, value, no_reply)
    end
  end

  def replace(key, flag, exp_time, size, value, no_reply)
    mc = Memcached.new
    # Transformation of received data to desired type
    string_key = String(key)
    key_exists = mc.hash_has_key(string_key)
    if key_exists == true
      set(key, flag, exp_time, size, value, no_reply)
    else
      if no_reply == false
        NOT_STORED
      end
    end
  end

  def pend(key, size, new_value, no_reply)
    mc = Memcached.new
    string_key = String(key)
    int_size = Integer(size)
    # hash_value is the value of the key => value association in the hash.
    hash_value = mc.hash_fetch(string_key)
    # array_* is the value of each position of the previous obtained array
    saved_flag = hash_value.instance_variable_get(:@flag)
    saved_exp_time = hash_value.instance_variable_get(:@exp_time)
    saved_size = hash_value.instance_variable_get(:@size)
    # Sum new size to the previous size in order to keep association between size and value
    new_size = saved_size + int_size
    new_cas_value = @stored_cas_value+1
    new_value_length = new_value.length

    if new_value_length > new_size
      CE_BDC
    else
      mc_obj = Memcached.new(flag: saved_flag, exp_time: saved_exp_time, size: new_size, cas_value: new_cas_value, value: new_value)
      mc.hash_store(string_key, mc_obj)
      @stored_cas_value = new_cas_value
      if no_reply == false
        STORED
      end
    end
  end

  def get_saved_value(key)
    mc = Memcached.new
    string_key = String(key)
    check_key_existence = mc.hash_has_key(string_key)
    if check_key_existence == false
      saved_value = NOT_STORED
    else
      hash_value = mc.hash_fetch(string_key)
      saved_value = hash_value.instance_variable_get(:@value)
    end
    saved_value
  end

  def append(key, size, value, no_reply)
    string_value = String(value)
    saved_value = get_saved_value(key)
    if saved_value == NOT_STORED
      if no_reply == false
        NOT_STORED
      end
    else
      new_value = saved_value.insert(-1, string_value)
      pend(key, size, new_value, no_reply)
    end
  end

  def prepend(key, size, value, no_reply)
    string_value = String(value)
    saved_value = get_saved_value(key)
    if saved_value == NOT_STORED
      if no_reply == false
        NOT_STORED
      end
    else
      new_value = saved_value.insert(0, string_value)
      pend(key, size, new_value, no_reply)
    end
  end

  def cas(key, flag, exp_time, size, cas_value, value, no_reply)
    mc = Memcached.new
    if cas_value.nil? == true
      ERROR
    else
      string_key = String(key)
      int_cas = Integer(cas_value)
      begin
        hash_value = mc.hash_fetch(string_key)
        saved_cas_value = hash_value.instance_variable_get(:@cas_value)
        if int_cas != saved_cas_value
          if no_reply == false
            EXISTS
          end
        else
          set(key, flag, exp_time, size, value, no_reply)
        end
      rescue
        if no_reply == false
          NOT_FOUND
        end
      end
    end
  end
end