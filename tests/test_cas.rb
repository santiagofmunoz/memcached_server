require_relative '../src/memcached.rb'
require 'test/unit'

class TestCas < Test::Unit::TestCase
  def test_normal_cas
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
    mc.cas_value = '1'

    assert_equal("STORED", mc.cas, "STORED should be returned")
    end

  def test_normal_cas_no_reply
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
    mc.cas_value = '1'

    assert_equal(nil, mc.cas, "nil should be returned")
  end

  def test_empty_cas_value
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

    assert_equal("ERROR", mc.cas, "ERROR should be returned")
  end

  def test_wrong_cas_value
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
    mc.cas_value = '2' # cas_value should be '1' because it the counter starts at '1'

    assert_equal("EXISTS", mc.cas, "EXISTS should be returned")
  end

  def test_wrong_key
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
    mc.cas_value = '1'

    assert_equal("NOT_FOUND", mc.cas, "NOT_FOUND should be returned")
  end

  def test_string_cas
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
    mc.cas_value = 'data'

    assert_equal("CLIENT_ERROR bad command line format", mc.check_data_integrity, "CLIENT_ERROR should be returned")
  end

  def test_non_existent_key_cas
    mc = Memcached.new
    mc.create_hash

    mc.key = '1'
    mc.flag = '3'
    mc.exp_time = '20000'
    mc.size = '15'
    mc.no_reply = false
    mc.value = 'anotherdatatest'
    mc.cas_value = '1'

    assert_equal("NOT_FOUND", mc.cas, "NOT_FOUND should be returned")
  end
end