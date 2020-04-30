require 'socket'
require_relative 'memcached'
require_relative 'storage'
require_relative 'retrieval'

class Connection
  def start
    port = 11211
    puts "Starting server..."
    server = TCPServer.new(port)
    mc = Memcached.new
    store = Storage.new
    retrieve = Retrieval.new
    mc.create_hash
    puts "Server started."

    loop do
      socket = server.accept
      Thread.new(socket) {
        client_input = socket.gets.chomp

        until client_input == "quit"
          split_string = client_input.split

          if split_string[0] == 'set' || split_string[0] == 'add'
            mc.key = split_string[1]
            store.flag = split_string[2]
            store.exp_time = split_string[3]
            store.size = split_string[4]
            second_input = socket.gets.chomp
            store.value = second_input
            if split_string[0] == 'set'
              socket.puts store.set
            elsif split_string[0] == 'add'
              socket.puts store.add
            end

          elsif split_string[0] == 'get'
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