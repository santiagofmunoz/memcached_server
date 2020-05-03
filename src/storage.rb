require 'date'

class Storage < Memcached

  attr_accessor :flag, :exp_time, :size, :value

  def set
    # Transformation of received data to desired type
    string_key = String(@key)
    int_flag = Integer(@flag)
    int_exp_time = Integer(@exp_time)
    int_size = Integer(@size)
    string_value = String(@value)
    value_length = string_value.length

    # Check if the size of the data sent is larger than the specified size
    if value_length > int_size
      "CLIENT_ERROR bad data chunk"
    else
      # Check if data has expiration time
      # The expiration time is standardised to UNIX time
      if int_exp_time == 0
        unix_expiration_time = 0;
      else
        expiration_time = Time.now + int_exp_time
        unix_expiration_time = expiration_time.strftime("%s")
      end

      @@hash_table[string_key] = [
          int_flag,
          unix_expiration_time,
          int_size,
          string_value
      ]
      # Check if the data was correctly saved
      is_saved = @@hash_table.has_key? string_key
      if is_saved
        "STORED"
      else
        "NOT STORED"
      end
    end
  end

  def add
    # Transformation of received data to desired type
    string_key = String(@key)
    key_exists = @@hash_table.key? string_key
    if key_exists == true
      "NOT STORED"
    else
      set
    end
  end

  def replace
    # Transformation of received data to desired type
    string_key = String(@key)
    key_exists = @@hash_table.key? string_key
    if key_exists == true
      set
    else
      "NOT STORED"
    end
  end

  def append
    string_key = String(@key)
    int_size = Integer(@size)
    string_value = String(@value)
    # hash_value is the value of the key => value association in the hash.
    hash_value = @@hash_table.fetch(string_key)
    # array_* is the value of each position of the previous obtained array
    array_flag = hash_value[0]
    array_exp_time = hash_value[1]
    array_size = hash_value[2]
    array_value = hash_value[3]
    # Sum new size to the previous size in order to keep association between size and value
    new_size = int_size + array_size
    new_value = array_value.insert(-1, string_value)
    new_value_length = new_value.length

    if new_value_length > new_size
      "CLIENT_ERROR bad data chunk"
    else
      @@hash_table[string_key] = [
          array_flag,
          array_exp_time,
          new_size,
          new_value,
      ]
      # Check if the data was correctly saved
      is_saved = @@hash_table.has_key? string_key
      if is_saved
        "STORED"
      else
        "NOT STORED"
      end
    end
  end

  def prepend
    string_key = String(@key)
    int_size = Integer(@size)
    string_value = String(@value)
    # hash_value is the value of the key => value association in the hash.
    hash_value = @@hash_table.fetch(string_key)
    # array_* is the value of each position of the previous obtained array
    array_flag = hash_value[0]
    array_exp_time = hash_value[1]
    array_size = hash_value[2]
    array_value = hash_value[3]
    # Sum new size to the previous size in order to keep association between size and value
    new_size = int_size + array_size
    new_value = array_value.insert(0, string_value)
    new_value_length = new_value.length

    if new_value_length > new_size
      "CLIENT_ERROR bad data chunk"
    else
      @@hash_table[string_key] = [
          array_flag,
          array_exp_time,
          new_size,
          new_value,
      ]
      # Check if the data was correctly saved
      is_saved = @@hash_table.has_key? string_key
      if is_saved
        "STORED"
      else
        "NOT STORED"
      end
    end
  end
end