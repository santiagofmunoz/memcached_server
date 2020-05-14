require_relative 'memcached'

class Retrieval
  def get_and_gets(keys)
    mc = Memcached.new
    # Creation of the string to be sent to the client
    final_string = ""
    # Make sure that the key is an array, in order to handle multiple key values
    array_key = Array(keys)
    @cmd = array_key[0]
    array_key[1..-1].each do |key|
      # Save which command was issued for later use

      string_key = String(key)
      # If the key doesn't exist, no error is returned.
      if mc.hash_empty == false
        begin
          hash_table_value = mc.hash_key(string_key)
          hash_flag = hash_table_value.instance_variable_get(:@flag)
          hash_size = hash_table_value.instance_variable_get(:@size)
          hash_value = hash_table_value.instance_variable_get(:@value)


          # Depending on the command issued, the program will return different strings
          if @cmd == 'get'
            final_string += "VALUE: #{string_key} #{hash_flag} #{hash_size}\n#{hash_value}\n"
          elsif @cmd == 'gets'
            hash_cas = hash_table_value.instance_variable_get(:@cas_value)
            final_string += "VALUE: #{string_key} #{hash_flag} #{hash_size} #{hash_cas}\n#{hash_value}\n"
          end
        rescue NoMethodError => e

        end
      end
    end
    # Added "END" due to protocol requirements.
    final_string += 'END'
    final_string
  end
end