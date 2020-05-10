require 'test/unit'
require_relative '../src/memcached.rb'

class TestGetAndGets < Test::Unit::TestCase

  # ================
  # |    SINGLE    |
  # ================

  def test_normal_single_get
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.value = 'datatest'
    mc.set

    mc.key = ['get', '1']
    assert_equal("VALUE: 1 2 8\ndatatest\nEND", mc.get_and_gets, "VALUE should be returned")
  end

  def test_non_existent_key_single_get
    mc = Memcached.new
    mc.create_hash
    mc.key = ['get', '1']
    assert_equal("END", mc.get_and_gets, "END should be returned")
  end

  def test_non_existent_key_single_gets
    mc = Memcached.new
    mc.create_hash
    mc.key = ['gets', '1']
    assert_equal("END", mc.get_and_gets, "END should be returned")
  end

  def test_normal_single_gets
    mc = Memcached.new
    mc.create_hash
    mc.key = '1'
    mc.flag = '2'
    mc.exp_time = '10000'
    mc.size = '8'
    mc.value = 'datatest'
    mc.set

    mc.key = ['gets', '1']
    assert_equal("VALUE: 1 2 8 1\ndatatest\nEND", mc.get_and_gets, "VALUE should be returned")
  end

  # ==========================================================================================
  # |                                        MULTIPLE                                        |
  # |  You can modify these test adding as many keys as you want and it *should* still work  |
  # ==========================================================================================

  def test_normal_multiple_get
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
    mc.exp_time = '10000'
    mc.size = '9'
    mc.value = 'datatest1'
    mc.set

    mc.key = ['get', '1', '2']
    assert_equal("VALUE: 1 2 8\ndatatest\nVALUE: 2 3 9\ndatatest1\nEND", mc.get_and_gets, "Two or more 'VALUE' should be returned")
  end

  def test_non_existent_key_multiple_get
    mc = Memcached.new
    mc.create_hash
    mc.key = ['get', '1', '2']
    assert_equal("END", mc.get_and_gets, "END should be returned")
  end

  def test_non_existent_key_multiple_gets
    mc = Memcached.new
    mc.create_hash
    mc.key = ['gets', '1', '2']
    assert_equal("END", mc.get_and_gets, "END should be returned")
  end

  def test_normal_multiple_gets
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
    mc.exp_time = '10000'
    mc.size = '9'
    mc.value = 'datatest1'
    mc.set

    mc.key = ['get', '1', '2']
    assert_equal("VALUE: 1 2 8\ndatatest\nVALUE: 2 3 9\ndatatest1\nEND", mc.get_and_gets, "Two or more 'VALUE' should be returned")
  end
end