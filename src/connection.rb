require 'socket'
require_relative 'memcached'

class Connection
  def start
    port = 11211
    puts "Starting server..."
    server = TCPServer.new(port)
    mc = Memcached.new
    mc.createHashTable
    puts "Server started."

    loop do
      socket = server.accept
      Thread.new(socket) {

        client_input = socket.gets.chomp

        until client_input == "quit"
          socket.puts "You said: #{client_input}!"
          client_input = socket.gets.chomp
        end

        socket.puts "Leaving server..."

        socket.close
      }
    end
  end
end