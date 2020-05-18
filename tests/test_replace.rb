require 'test/unit'
require_relative '../src/storage'

class TestReplace < Test::Unit::TestCase

  STORED = "STORED"
  STORED_MESSAGE = "STORED should be returned"
  NOT_STORED = "NOT_STORED"
  NOT_STORED_MESSAGE = "NOT_STORED should be returned"
  NIL_MESSAGE = "nil should be returned"

  def setup
    @key = '1'
    @flag = 2
    @exp_time = 10000
    @size = 8
    @value = 'datatest'
    @no_reply = false
    @store = Storage.new
    @store.initialize_stored_cas_value

    @key2 = '2'
    @flag2 = 3
    @exp_time2 = 20000
    @size2 = 15
    @value2 = 'anotherdatatest'
  end

  def test_existent_data
    # Creation of an element
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    assert_equal(STORED, @store.replace(@key, @flag2, @exp_time2, @size2, @value2, @no_reply), STORED_MESSAGE)
  end

  def test_existent_data_no_reply
    # Creation of an element
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    no_reply = true
    assert_equal(nil, @store.replace(@key, @flag2, @exp_time2, @size2, @value2, no_reply), NIL_MESSAGE)
  end

  def test_non_existent_data
    # Creation of an element
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = '3'
    assert_equal(NOT_STORED, @store.replace(key, @flag2, @exp_time2, @size2, @value2, @no_reply), NOT_STORED_MESSAGE)
  end

  def test_non_existent_data_no_reply
    # Creation of an element
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    no_reply = true
    assert_equal(nil, @store.replace(@key2, @flag2, @exp_time2, @size2, @value2, no_reply), NIL_MESSAGE)
  end
end