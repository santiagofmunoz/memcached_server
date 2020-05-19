require 'test/unit'
require 'socket'
require_relative '../src/connection'

# *IMPORTANT*
# In order to run these tests, you must have the server running.
# Otherwise, several errors will be returned.

class TestConnection < Test::Unit::TestCase

  IP_ADDRESS = '127.0.0.1'
  PORT = 11211
  CONN_MESSAGE = "The connection object should be returned"

  def test_normal_connection
    socket = TCPSocket.new(IP_ADDRESS, PORT)
    assert_equal(socket, socket, CONN_MESSAGE)
  end

  def test_wrong_ip_address_connection
    ip_address = '127.0.0.2'
    assert_raises Errno::ECONNREFUSED do
      TCPSocket.new(ip_address, PORT)
    end
  end

  def test_wrong_port_connection
    port = 11212
    assert_raises Errno::ECONNREFUSED do
      TCPSocket.new(IP_ADDRESS, port)
    end
  end
end