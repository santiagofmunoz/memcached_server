require 'date'
require_relative 'memcached'

class Storage

  attr_accessor :stored_cas_value

  ERROR = 'ERROR'
  CE_BCLF = 'CLIENT_ERROR bad command line format'
  CE_BDC = 'CLIENT_ERROR bad data chunk'
  STORED = 'STORED'
  NOT_STORED = 'NOT_STORED'
  EXISTS = 'EXISTS'
  NOT_FOUND = 'NOT_FOUND'

  def initialize_stored_cas_value
    @stored_cas_value = 0
  end

  def check_data_integrity(key, flag, exp_time, size, cas_value)
    if key.nil? == true || flag.nil? == true || exp_time.nil? == true || size.nil? == true
      ERROR
    else
      begin
        String(key)
        int_flag = Integer(flag)
        Integer(exp_time)
        int_size = Integer(size)
        if cas_value.nil? == false
          Integer(cas_value)
        end
        if int_flag < 0 || int_size < 0
          CE_BCLF
        else
          'OK'
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
    value_length = string_value.length

    # Check if value length data is correct. This check is made here and not in
    # check_data_integrity because the data block is needed to check the size.
    # check_data_integrity is executed before the value is inserted.
    if value_length > int_size
      CE_BDC
    else
      # Check if data has expiration time
      # The expiration time is standardised to UNIX time
      if int_exp_time == 0
        unix_expiration_time = 0;
      else
        unix_time_now = Integer(Time.now.strftime("%s"))
        if int_exp_time >= unix_time_now
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
    array_flag = hash_value[0]
    array_exp_time = hash_value[1]
    array_size = hash_value[2]
    # Sum new size to the previous size in order to keep association between size and value
    new_size = int_size + array_size
    new_cas_value = @stored_cas_value+1
    new_value_length = new_value.length

    if new_value_length > new_size
      CE_BDC
    else
      mc_obj = Memcached.new(flag: array_flag, exp_time: array_exp_time, size: new_size, cas_value: new_cas_value, value: new_value)
      mc.hash_store(string_key, mc_obj)
      @stored_cas_value = new_cas_value
      if no_reply == false
        STORED
      end
    end
  end

  def get_array_value(key)
    mc = Memcached.new
    string_key = String(key)
    check_key_existence = mc.hash_has_key(string_key)
    if check_key_existence == false
      array_value = NOT_STORED
    else
      hash_value = mc.hash_fetch(string_key)
      array_value = hash_value[3]
    end
    array_value
  end

  def append(key, size, value, no_reply)
    string_value = String(value)
    array_value = get_array_value(key)
    if array_value == NOT_STORED
      if no_reply == false
        NOT_STORED
      end
    else
      new_value = array_value.insert(-1, string_value)
      pend(key, size, new_value, no_reply)
    end
  end

  def prepend(key, size, value, no_reply)
    string_value = String(value)
    array_value = get_array_value(key)
    if array_value == NOT_STORED
      if no_reply == false
        NOT_STORED
      end
    else
      new_value = array_value.insert(0, string_value)
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
        hash_cas_value = hash_value[4]
        if int_cas != hash_cas_value
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