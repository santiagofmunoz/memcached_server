require_relative '../src/memcached.rb'
require 'test/unit'

class TestReplace < Test::Unit::TestCase
  def test_existent_data
    # Creation of an element
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    mc.set

    mc.key = '1'
    mc.flag = '3'
    mc.exp_time = '20000'
    mc.size = '15'
    mc.no_reply = false
    mc.value = 'anotherdatatest'
    assert_equal("STORED", mc.replace, "STORED should be returned")
  end

  def test_existent_data_no_reply
    # Creation of an element
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    mc.set

    mc.key = '1'
    mc.flag = '3'
    mc.exp_time = '20000'
    mc.size = '15'
    mc.no_reply = true
    mc.value = 'anotherdatatest'
    assert_equal(nil, mc.replace, "nil should be returned")
  end

  def test_non_existent_data
    # Creation of an element
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    mc.set

    mc.key = '2'
    mc.flag = '3'
    mc.exp_time = '20000'
    mc.size = '15'
    mc.no_reply = false
    mc.value = 'anotherdatatest'
    assert_equal("NOT_STORED", mc.replace, "STORED should be returned")
  end
end