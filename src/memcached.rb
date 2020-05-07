require 'date'

class Memcached

  attr_accessor :hash_table, :key, :flag, :exp_time, :size, :value, :cas_value

  def initialize
    @stored_cas_value = 0
  end

  # This method must be called ONCE and ONLY when the server is started
  # otherwise the table will be regenerated and emptied.
  def create_hash
    @hash_table = Hash.new
  end

  # ==========================
  # |    STORAGE COMMANDS    |
  # ==========================

  def check_data_integrity
    if @key == nil || @flag == nil || @exp_time == nil || @size == nil
      "ERROR"
    else
      begin
        string_key = String(@key)
        int_flag = Integer(@flag)
        int_exp_time = Integer(@exp_time)
        int_size = Integer(@size)
        string_value = String(@value)
        int_cas = Integer(@cas_value)
        "OK"
      rescue ArgumentError => e
        "CLIENT_ERROR bad command line format"
      end
    end
  end

  def set
    # Transformation of received data to desired type
    string_key = String(@key)
    int_flag = Integer(@flag)
    int_exp_time = Integer(@exp_time)
    int_size = Integer(@size)
    string_value = String(@value)
    new_cas_value = @stored_cas_value+1
    value_length = string_value.length

    # Check if received data is correct.
    if int_flag < 0 || int_size < 0
      "CLIENT_ERROR bad command line format"
    elsif value_length > int_size
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
      @hash_table[string_key] = [
          int_flag,
          unix_expiration_time,
          int_size,
          string_value,
          new_cas_value
      ]
      # Check if the data was correctly saved
      is_saved = @hash_table.has_key? string_key
      if is_saved
        @stored_cas_value = new_cas_value
        "STORED"
      else
        "NOT_STORED"
      end
    end
  end

  def add
    # Transformation of received data to desired type
    string_key = String(@key)
    key_exists = @hash_table.key? string_key
    if key_exists == true
      "NOT_STORED"
    else
      set
    end
  end

  def replace
    # Transformation of received data to desired type
    string_key = String(@key)
    key_exists = @hash_table.key? string_key
    if key_exists == true
      set
    else
      "NOT_STORED"
    end
  end

  def pend(new_value)
    string_key = String(@key)
    int_size = Integer(@size)
    # hash_value is the value of the key => value association in the hash.
    hash_value = @hash_table.fetch(string_key)
    # array_* is the value of each position of the previous obtained array
    array_flag = hash_value[0]
    array_exp_time = hash_value[1]
    array_size = hash_value[2]
    # Sum new size to the previous size in order to keep association between size and value
    new_size = int_size + array_size
    new_cas_value = @stored_cas_value+1
    new_value_length = new_value.length

    if new_value_length > new_size
      "CLIENT_ERROR bad data chunk"
    else
      @hash_table[string_key] = [
          array_flag,
          array_exp_time,
          new_size,
          new_value,
          new_cas_value
      ]
      # Check if the data was correctly saved
      is_saved = @hash_table.has_key? string_key
      if is_saved
        @stored_cas_value = new_cas_value
        "STORED"
      else
        "NOT_STORED"
      end
    end
  end

  def get_array_value
    string_key = String(@key)
    check_key_existence = @hash_table.key? string_key
    if check_key_existence == false
      array_value = "NOT_STORED"
    else
      hash_value = @hash_table.fetch(string_key)
      array_value = hash_value[3]
    end
    return array_value # This 'return' word was left in order to keep code readability.
  end

  def append
    string_value = String(@value)
    array_value = get_array_value
    if array_value == "NOT_STORED"
      "NOT_STORED"
    else
      new_value = array_value.insert(-1, string_value)
      pend(new_value)
    end
  end

  def prepend
    string_value = String(@value)
    array_value = get_array_value
    if array_value == "NOT_STORED"
      "NOT_STORED"
    else
      new_value = array_value.insert(0, string_value)
      pend(new_value)
    end
  end

  #TODO cas command
  def cas
    if @cas_value == nil
      "ERROR"
    else
      string_key = String(@key)
      int_cas = Integer(@cas_value)
      begin
        hash_value = @hash_table.fetch(string_key)
        cas_value = hash_value[4]
        if int_cas != cas_value
          "EXISTS"
        else
          set
        end
      rescue
        "NOT_FOUND"
      end
    end
  end

  # ============================
  # |    RETRIEVAL COMMANDS    |
  # ============================

  def get_and_gets
    # Creation of the string to be sent to the client
    final_string = ""
    # Make sure that the key is an array, in order to handle multiple key values
    array_key = Array(@key)
    array_key.each do |key|
      # Save which command was issued for later use
      if key == 'get' || key == 'gets'
        @cmd = key
      end

      string_key = String(key)
      # If the key doesn't exist, no error is returned.
      if @hash_table.empty? == false
        begin
          hash_table_value = @hash_table[string_key]
          hash_flag = hash_table_value[0]
          hash_size = hash_table_value[2]
          hash_value = hash_table_value[3]

          # Depending on the command issued, the program will return different strings
          if @cmd == 'get'
            final_string += "VALUE: #{string_key} #{hash_flag} #{hash_size}\n#{hash_value}\n"
          elsif @cmd == 'gets'
            hash_cas = hash_table_value[4]
            final_string += "VALUE: #{string_key} #{hash_flag} #{hash_size} #{hash_cas}\n#{hash_value}\n"
          end
        rescue NoMethodError => e

        end
      end
    end
    # Added "END" due to protocol requirements.
    final_string += "END"
    final_string
  end

  # ============================
  # |    PURGE EXPIRED KEYS    |
  # ============================

  def search_expired_keys
    if @hash_table.empty? == false
      count = 0
      now = Time.now.strftime("%s")
      log_date = Time.now.strftime("%d/%m/%Y %H:%M:%S")
      @hash_table.each do |key, value|
        exp_time = value[1]
        if exp_time != 0
          if exp_time < now
            @hash_table.delete(key)
            count = count+1
          end
        end
      end
      puts "[#{log_date}] #{count} expired keys have been purged"
    end
  end
end