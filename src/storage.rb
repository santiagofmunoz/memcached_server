class Storage < Memcached

  attr_accessor :flag, :exp_time, :size, :value

  def set
    int_size = Integer(@size)
    value_length = @value.length

    if value_length > int_size
      "ERROR"
    else
      int_flag = Integer(@flag)
      int_exp_time = Integer(@exp_time)
      expiration_time = Time.now + int_exp_time
      unix_expiration_time = expiration_time.strftime("%s")
      @hash_table[@key] = [
          "flag" => int_flag,
          "exp_time" => unix_expiration_time,
          "size" => int_size,
          "value" => @value
      ]
      is_saved = @hash_table.has_key?(@key)
      if is_saved
        "STORED"
      else
        "NOT STORED"
      end
    end
  end
end