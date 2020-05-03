require 'socket'
require_relative 'memcached'
require_relative 'storage'
require_relative 'retrieval'

class Connection
  def start
    # Definition of variables, instances, hash creation and server start.
    ip_server = "127.0.0.1" # Change this IP Address to the one you desire
    port = 11211 # Change this port number to the one you desire
    puts "Starting server..."
    server = TCPServer.new(ip_server, port)
    mc = Memcached.new
    store = Storage.new
    retrieve = Retrieval.new
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

          # Variable declaration
          cmd = split_string[0]
          key = split_string[1]
          flag = split_string[2]
          exp_time = split_string[3]
          size = split_string[4]

          # Handling of storage commands
          if cmd == 'set' || cmd == 'add' || cmd == 'append' || cmd == 'prepend'
            mc.key = key
            store.flag = flag
            store.exp_time = exp_time
            store.size = size
            # With second_input we receive the data to be inserted
            second_input = socket.gets.chomp
            store.value = second_input
            case cmd
              when 'set'
                  socket.puts store.set
              when 'add'
                  socket.puts store.add
              when 'append'
                  socket.puts store.append
              when 'prepend'
                  socket.puts store.prepend
            end

          # Handling of retrieval commands
          elsif cmd == 'get'
            mc.key = split_string
            socket.puts retrieve.get
          end

          client_input = socket.gets.chomp
        end

        socket.puts "Leaving server..."
        socket.close
      }
    end
  end
end