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
    mutex = Mutex.new
    store = Storage.new
    retrieve = Retrieval.new
    store.initialize_stored_cas_value
    puts 'Server started.'

    # An infinite loop is made so the user can send multiple commands
    loop do
      socket = server.accept
      # Make the concurrency happen
      Thread.new(socket) {
        begin
          # Get command and parameters
          cmd_data = socket.gets.chomp
          if cmd_data == 'quit'
            socket.puts 'Leaving server...'
            socket.close
          end
        rescue NoMethodError
          socket.close
          Thread.exit
        end

        # Commands management, if the user writes "quit", the connection is closed.
        until cmd_data == 'quit'

          # Split client input to know which command was introduced
          split_ci = cmd_data.split
          cmd = split_ci[0]

          # Handling of retrieval commands
          if cmd == 'get' || cmd == 'gets'
            #Lock the system to prevent any modifications to the variables from other clients.
            mutex.synchronize {
              keys = split_ci
              socket.puts retrieve.get_and_gets(keys)
            }
          elsif cmd == 'set' || cmd == 'add' || cmd == 'replace' || cmd == 'append' || cmd == 'prepend' || cmd == 'cas'
            # Data block to be inserted
            value = socket.gets.chomp

            #Lock the system to prevent any modifications to the variables from other clients.
            mutex.synchronize {
              # Handling of storage commands
              key = split_ci[1]
              flag = split_ci[2]
              exp_time = split_ci[3]
              size = split_ci[4]

              if cmd == 'cas'
                cas_value = split_ci[5]
                if split_ci[6] == 'noreply'
                  no_reply = true
                else
                  no_reply = false
                end
              else
                cas_value = nil
                if split_ci[5] == 'noreply'
                  no_reply = true
                else
                  no_reply = false
                end
              end

              cdi = store.check_data_integrity(key, flag, exp_time, size, cas_value, value)
              if cdi == 'OK'

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
            }
          end

          begin
            # Get command and parameters
            cmd_data = socket.gets.chomp
          rescue NoMethodError
            socket.close
            Thread.exit
          end
        end

        begin
          socket.puts 'Leaving server...'
          socket.close
        rescue IOError

        end
      }
    end
  end
end