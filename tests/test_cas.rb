require 'test/unit'
require_relative '../src/storage'

class TestCas < Test::Unit::TestCase

  STORED = "STORED"
  STORED_MESSAGE = "STORED should be returned"
  ERROR = "ERROR"
  ERROR_MESSAGE = "ERROR should be returned"
  EXISTS = "EXISTS"
  EXISTS_MESSAGE = "EXISTS should be returned"
  NOT_FOUND = "NOT_FOUND"
  NOT_FOUND_MESSAGE = "NOT_FOUND should be returned"
  CE_BCLF = "CLIENT_ERROR bad command line format"
  CE_MESSAGE = "CLIENT_ERROR should be returned"
  NIL_MESSAGE = "nil should be returned"

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
    @flag2 = 3
    @exp_time2 = 20000
    @size2 = 15
    @value2 = 'anotherdatatest'
  end

  def test_normal_cas
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    assert_equal(STORED, @store.cas(@key, @flag2, @exp_time2, @size2, @cas_value, @value2, @no_reply), STORED_MESSAGE)
  end

  def test_normal_cas_no_reply
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    no_reply = true
    assert_equal(nil, @store.cas(@key, @flag2, @exp_time2, @size2, @cas_value, @value2, no_reply), NIL_MESSAGE)
  end

  def test_empty_cas_value
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    cas_value = nil
    assert_equal(ERROR, @store.cas(@key, @flag2, @exp_time2, @size2, cas_value, @value2, @no_reply), ERROR_MESSAGE)
  end

  def test_wrong_cas_value
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    cas_value = 2 # cas_value should be '1' because it the counter starts at '1'
    assert_equal(EXISTS, @store.cas(@key, @flag2, @exp_time2, @size2, cas_value, @value2, @no_reply), EXISTS_MESSAGE)
  end

  def test_wrong_key
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = '3'
    assert_equal(NOT_FOUND, @store.cas(key, @flag2, @exp_time2, @size2, @cas_value, @value2, @no_reply), NOT_FOUND_MESSAGE)
  end

  def test_string_cas
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    cas_value = 'data'
    assert_equal(CE_BCLF, @store.check_data_integrity(@key2, @flag2, @exp_time2, @size2, cas_value, @value2), CE_MESSAGE)
  end

  def test_non_existent_key_cas
    key = '3'
    assert_equal(NOT_FOUND, @store.cas(key, @flag2, @exp_time2, @size2, @cas_value, @value2, @no_reply), NOT_FOUND_MESSAGE)
  end
end