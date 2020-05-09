require_relative '../src/memcached.rb'
require 'test/unit'

# This test tests the commands 'append' and 'prepend'
class TestPend < Test::Unit::TestCase

  # ================
  # |    APPEND    |
  # ================

  def test_normal_append
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '13'
    mc.no_reply = false
    mc.value = '_appendeddata'
    assert_equal("STORED", mc.append, "STORED should be returned")
  end

  def test_normal_append_no_reply
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '13'
    mc.no_reply = true
    mc.value = '_appendeddata'
    assert_equal(nil, mc.append, "nil should be returned")
  end

  def test_non_existent_key_append
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '13'
    mc.no_reply = false
    mc.value = '_appendeddata'
    assert_equal("NOT_STORED", mc.append, "NOT_STORED should be returned")
  end

  # This test also applies for prepend.
  def test_string_size_append
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = 'data'
    mc.no_reply = false
    mc.value = '_appendeddata'
    assert_equal("CLIENT_ERROR bad command line format", mc.check_data_integrity, "CLIENT_ERROR should be returned")
  end

  def test_wrong_value_size_append
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '13'
    mc.no_reply = false
    mc.value = '_appendeddata1'
    assert_equal("CLIENT_ERROR bad data chunk", mc.append, "CLIENT_ERROR should be returned")
  end

  # =================
  # |    PREPEND    |
  # =================

  def test_normal_prepend
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '14'
    mc.no_reply = false
    mc.value = 'prependeddata_'
    assert_equal("STORED", mc.prepend, "STORED should be returned")
  end

  def test_normal_prepend_no_reply
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '14'
    mc.no_reply = true
    mc.value = 'prependeddata_'
    assert_equal(nil, mc.prepend, "nil should be returned")
  end

  def test_non_existent_key_prepend
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '14'
    mc.no_reply = false
    mc.value = 'prependeddata_'
    assert_equal("NOT_STORED", mc.prepend, "NOT_STORED should be returned")
  end

  def test_wrong_value_size_prepend
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
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '14'
    mc.no_reply = false
    mc.value = 'prependeddata_1'
    assert_equal("CLIENT_ERROR bad data chunk", mc.prepend, "CLIENT_ERROR should be returned")
  end
end