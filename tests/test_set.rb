require 'test/unit'
require_relative '../src/memcached.rb'

class TestSet < Test::Unit::TestCase

  def test_normal_set
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("STORED", mc.set, "STORED should be returned")
  end

  def test_normal_set_no_reply
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = true
    mc.value = 'datatest'
    assert_equal(nil, mc.set, "nil should be returned")
  end

  # ==============
  # |    FLAG    |
  # ==============

  def test_negative_flag
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '-1'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("CLIENT_ERROR bad command line format", mc.set, "CLIENT_ERROR should be returned")
  end

  def test_string_flag
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = 'data'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("CLIENT_ERROR bad command line format", mc.check_data_integrity, "CLIENT_ERROR should be returned")
  end

  def test_empty_flag
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.value = 'datatest'
    assert_equal("ERROR", mc.check_data_integrity, "ERROR should be returned")
  end

  # ==================
  # |    EXP_TIME    |
  # ==================

  def test_negative_exp_time
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '-1'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("STORED", mc.set, "STORED should be returned")
  end

  def test_string_exp_time
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = 'data'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("CLIENT_ERROR bad command line format", mc.check_data_integrity, "CLIENT_ERROR should be returned")
  end

  def test_empty_exp_time
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.value = 'datatest'
    assert_equal("ERROR", mc.check_data_integrity, "ERROR should be returned")
  end

  def test_seconds_exp_time
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("STORED", mc.set, "STORED should be returned")
  end

  def test_unix_exp_time
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '1640995199'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("STORED", mc.set, "STORED should be returned")
  end

  # ==============
  # |    SIZE    |
  # ==============

  def test_negative_size
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '-1'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("CLIENT_ERROR bad command line format", mc.set, "CLIENT_ERROR should be returned")
  end

  def test_string_size
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = 'data'
    mc.no_reply = false
    mc.value = 'datatest'
    assert_equal("CLIENT_ERROR bad command line format", mc.check_data_integrity, "CLIENT_ERROR should be returned")
  end

  def test_empty_size
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = 'data'
    mc.value = 'datatest'
    assert_equal("ERROR", mc.check_data_integrity, "ERROR should be returned")
  end

  # ===============
  # |    VALUE    |
  # ===============

  def test_empty_value
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = ''
    assert_equal("STORED", mc.set, "STORED should be returned")
  end

  def test_wrong_value_size
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.no_reply = false
    mc.value = 'datatest1'
    assert_equal("CLIENT_ERROR bad data chunk", mc.set, "CLIENT_ERROR should be returned")
  end
end