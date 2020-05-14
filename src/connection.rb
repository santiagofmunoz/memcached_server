require 'socket'
require_relative 'storage'
require_relative 'retrieval'

class Connection
  def start
    # Definition of variables, instances, hash creation and server start.
    ip_server = '127.0.0.1' # Change this IP Address to the one you desire
    port = 11211 # Change this port number to the one you desire
    puts 'Starting server...'
    server = TCPServer.new(ip_server, port)
    store = Storage.new
    retrieve = Retrieval.new
    store.initialize_stored_cas_value
    puts 'Server started.'

    # An infinite loop is made so the user can send multiple commands
    loop do
      socket = server.accept
      # Make the concurrency happen
      Thread.new(socket) {
        # Get user's input
        client_input = socket.gets.chomp

        # Commands management, if the user writes "quit", the connection is closed.
        until client_input == 'quit'
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

            if cmd == 'cas'
              cas_value = split_string[5]
              if split_string[6] == 'noreply'
                no_reply = true
              else
                no_reply = false
              end
            else
              cas_value = nil
              if split_string[5] == 'noreply'
                no_reply = true
              else
                no_reply = false
              end
            end

            cdi = store.check_data_integrity(key, flag, exp_time, size, cas_value)
            if cdi == 'OK'
              # With value we receive the data block to be inserted
              value = socket.gets.chomp

              case cmd
              when 'set'
                socket.puts store.set(key, flag, exp_time, size, value, no_reply)
              when 'add'
                socket.puts store.add(key, flag, exp_time, size, value, no_reply)
              when 'replace'
                socket.puts store.replace(key, flag, exp_time, size, value, no_reply)
              when 'append'
                socket.puts store.append(key, size, value, no_reply)
              when 'prepend'
                socket.puts store.prepend(key, size, value, no_reply)
              when 'cas'
                socket.puts store.cas(key, flag, exp_time, size, cas_value, value, no_reply)
              end
            else
              socket.puts cdi
            end

          # Handling of retrieval commands
          elsif cmd == 'get' || cmd == 'gets'
            keys = split_string
            socket.puts retrieve.get_and_gets(keys)
          end

          client_input = socket.gets.chomp
        end

        socket.puts 'Leaving server...'
        socket.close
      }
    end
  end
end