require 'socket'
require_relative 'memcached'

class Connection
  def start
    # Definition of variables, instances, hash creation and server start.
    ip_server = "127.0.0.1" # Change this IP Address to the one you desire
    port = 11211 # Change this port number to the one you desire
    puts "Starting server..."
    server = TCPServer.new(ip_server, port)
    mc = Memcached.new
    mc.create_hash
    puts "Server started."

    # An infinite loop is made so the user can send multiple commands
    loop do
      socket = server.accept
      # Make the concurrency happen
      Thread.new(socket) {
        # Get user's input
        client_input = socket.gets.chomp

        # Commands management, if the user writes "quit", the connection is closed.
        until client_input == "quit"
          # Split user's input to know which command was introduced
          split_string = client_input.split
          cmd = split_string[0]

          # Handling of storage commands
          if cmd == 'set' ||
              cmd == 'add' ||
              cmd == 'replace' ||
              cmd == 'append' ||
              cmd == 'prepend' ||
              cmd == 'cas'

            key = split_string[1]
            flag = split_string[2]
            exp_time = split_string[3]
            size = split_string[4]

            mc.key = key
            mc.flag = flag
            mc.exp_time = exp_time
            mc.size = size

            if cmd == 'cas'
              cas_value = split_string[5]
              mc.cas_value = cas_value
              if split_string[6] == "noreply"
                mc.no_reply = true
              else
                mc.no_reply = false
              end
            else
              if split_string[5] == "noreply"
                mc.no_reply = true
              else
                mc.no_reply = false
              end
            end

            cdi = mc.check_data_integrity
            if cdi == "OK"
              # With second_input we receive the data to be inserted
              second_input = socket.gets.chomp
              mc.value = second_input
              case cmd
              when 'set'
                mc.search_expired_keys
                socket.puts mc.set
              when 'add'
                mc.search_expired_keys
                socket.puts mc.add
              when 'replace'
                mc.search_expired_keys
                socket.puts mc.replace
              when 'append'
                mc.search_expired_keys
                socket.puts mc.append
              when 'prepend'
                mc.search_expired_keys
                socket.puts mc.prepend
              when 'cas'
                mc.search_expired_keys
                socket.puts mc.cas
              end
            else
              socket.puts cdi
            end

          # Handling of retrieval commands
          elsif cmd == 'get' || cmd == 'gets'
            mc.key = split_string
            mc.search_expired_keys
            socket.puts mc.get_and_gets
          end

          client_input = socket.gets.chomp
        end

        socket.puts "Leaving server..."
        socket.close
      }
    end
  end
end