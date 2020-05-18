require 'test/unit'
require_relative '../src/storage'

# This test tests the commands 'append' and 'prepend'
class TestPend < Test::Unit::TestCase

  STORED = "STORED"
  STORED_MESSAGE = "STORED should be returned"
  NOT_STORED = "NOT_STORED"
  NOT_STORED_MESSAGE = "NOT_STORED should be returned"
  NIL_MESSAGE = "nil should be returned"
  CE_BDC = "CLIENT_ERROR bad data chunk"
  CE_MESSAGE = "CLIENT_ERROR should be returned"

  def setup
    @key = '1'
    @flag = 2
    @exp_time = 10000
    @size = 8
    @cas_value = 1
    @value = 'datatest'
    @no_reply = false
    @store = Storage.new
    @store.initialize_stored_cas_value

    @key2 = '2'
    @size_append = 13
    @size_prepend = 14
    @value_append = '_appendeddata'
    @value_prepend = 'prependeddata_'
  end

  # ================
  # |    APPEND    |
  # ================

  def test_normal_append
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    assert_equal(STORED, @store.append(@key, @size_append, @value_append, @no_reply), STORED_MESSAGE)
  end

  def test_normal_append_no_reply
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    no_reply = true
    assert_equal(nil, @store.append(@key, @size_append, @value_append, no_reply), NIL_MESSAGE)
  end

  def test_non_existent_key_append
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = '3'
    assert_equal(NOT_STORED, @store.append(key, @size_append, @value_append, @no_reply), NOT_STORED_MESSAGE)
  end

  def test_wrong_value_size_append
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    value = '_appendeddata1'
    assert_equal(CE_BDC, @store.append(@key, @size_append, value, @no_reply), CE_MESSAGE)
  end

  # =================
  # |    PREPEND    |
  # =================

  def test_normal_prepend
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    assert_equal(STORED, @store.prepend(@key, @size_prepend, @value_prepend, @no_reply), STORED_MESSAGE)
  end

  def test_normal_prepend_no_reply
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    no_reply = true
    assert_equal(nil, @store.prepend(@key, @size_prepend, @value_prepend, no_reply), NIL_MESSAGE)
  end

  def test_non_existent_key_prepend
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = '3'
    assert_equal(NOT_STORED, @store.prepend(key, @size_prepend, @value_prepend, @no_reply), NOT_STORED_MESSAGE)
  end

  def test_wrong_value_size_prepend
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    value = 'prependeddata_1'
    assert_equal(CE_BDC, @store.prepend(@key, @size_prepend, value, @no_reply), CE_MESSAGE)
  end
end