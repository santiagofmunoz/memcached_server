require 'test/unit'
require_relative '../src/storage'

class TestSet < Test::Unit::TestCase

  STORED = "STORED"
  STORED_MESSAGE = "STORED should be returned"
  NIL_MESSAGE = "nil should be returned"

  def setup
    @key = '1'
    @flag = 2
    @exp_time = 10000
    @size = 8
    @cas_value = 1
    @no_reply = false
    @value = 'datatest'
    @store = Storage.new
    @store.initialize_stored_cas_value
  end

  def test_normal_set
    assert_equal(STORED, @store.set(@key, @flag, @exp_time, @size, @value, @no_reply), STORED_MESSAGE)
  end

  def test_normal_set_no_reply
    no_reply = true
    assert_equal(nil, @store.set(@key, @flag, @exp_time, @size, @value, no_reply), NIL_MESSAGE)
  end

  # ==================
  # |    EXP_TIME    |
  # ==================

  def test_seconds_exp_time
    exp_time = '10000'
    assert_equal(STORED, @store.set(@key, @flag, exp_time, @size, @value, @no_reply), STORED_MESSAGE)
  end

  def test_unix_exp_time
    exp_time = '1640995199'
    assert_equal(STORED, @store.set(@key, @flag, exp_time, @size, @value, @no_reply), STORED_MESSAGE)
  end

  # ===============
  # |    VALUE    |
  # ===============

  def test_empty_value
    value = ''
    assert_equal(STORED, @store.set(@key, @flag, @exp_time, @size, value, @no_reply), STORED_MESSAGE)
  end

end