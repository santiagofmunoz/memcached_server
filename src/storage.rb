require 'date'

class Storage < Memcached

  attr_accessor :flag, :exp_time, :size, :value

  def set
    int_size = Integer(@size)
    string_value = String(@value)
    value_length = string_value.length

    if value_length > int_size
      "ERROR"
    else
      string_key = String(@key)
      int_flag = Integer(@flag)
      int_exp_time = Integer(@exp_time)

      if int_exp_time == 0
        unix_expiration_time = 0;
      else
        expiration_time = Time.now + int_exp_time
        unix_expiration_time = expiration_time.strftime("%s")
      end

      @@hash_table[string_key] = [
          "flag" => int_flag,
          "exp_time" => unix_expiration_time,
          "size" => int_size,
          "value" => string_value
      ]
      is_saved = @@hash_table.has_key? string_key
      if is_saved
        "STORED"
      else
        "NOT STORED"
      end
    end
  end

  def add
    string_key = String(@key)
    key_exists = @@hash_table.key? string_key
    if key_exists == true
      "NOT STORED"
    else
      set
    end
  end

  def replace
    string_key = String(@key)
    key_exists = @@hash_table.key? string_key
    if key_exists == true
      set
    else
      "NOT STORED"
    end
  end

end