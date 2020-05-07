require_relative '../src/memcached.rb'
require 'test/unit'

class TestAdd < Test::Unit::TestCase
  # The rest of the tests are the ones in test_set since the method only checks if the data already exists
  def test_existent_data
    # Creation of an element
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.value = 'datatest'
    mc.set

    mc.key = '1'
    mc.flag = '3'
    mc.exp_time = '20000'
    mc.size = '15'
    mc.value = 'anotherdatatest'
    assert_equal("NOT_STORED", mc.add, "NOT_STORED should be returned")
  end

  def test_non_existent_data
    # Creation of an element
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.value = 'datatest'
    mc.set

    mc.key = '2'
    mc.flag = '3'
    mc.exp_time = '20000'
    mc.size = '15'
    mc.value = 'anotherdatatest'
    assert_equal("STORED", mc.add, "STORED should be returned")
  end
end