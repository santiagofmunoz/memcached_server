require 'test/unit'
require_relative '../src/retrieval'
require_relative '../src/storage'

class TestGetAndGets < Test::Unit::TestCase

  VALUE_MESSAGE = "VALUE should be returned"
  MULTIPLE_VALUE_MESSAGE = "Two or more 'VALUE' should be returned"
  END_MESSAGE = "END should be returned"

  def setup
    @retrieve = Retrieval.new
    @store = Storage.new
    @store.initialize_stored_cas_value

    @key = '1'
    @flag = 2
    @exp_time = 10000
    @size = 8
    @value = 'datatest'
    @no_reply = false

    @key2 = '2'
    @flag2 = 3
    @exp_time2 = 20000
    @size2 = 15
    @value2 = 'anotherdatatest'
  end

  # ================
  # |    SINGLE    |
  # ================

  def test_normal_single_get
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = ['get', '1']
    assert_equal("VALUE: 1 2 8\ndatatest\nEND", @retrieve.get_and_gets(key), VALUE_MESSAGE)
  end

  def test_normal_single_gets
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = ['gets', '1']
    assert_equal("VALUE: 1 2 8 1\ndatatest\nEND", @retrieve.get_and_gets(key), VALUE_MESSAGE)
  end

  def test_non_existent_key_single_get
    key = ['get', '3']
    assert_equal("END", @retrieve.get_and_gets(key), END_MESSAGE)
  end

  def test_non_existent_key_single_gets
    key = ['gets', '3']
    assert_equal("END", @retrieve.get_and_gets(key), END_MESSAGE)
  end

  # ==========================================================================================
  # |                                        MULTIPLE                                        |
  # |  You can modify these test adding as many keys as you want and it *should* still work  |
  # ==========================================================================================

  def test_normal_multiple_get
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)
    @store.set(@key2, @flag2, @exp_time2, @size2, @value2, @no_reply)

    keys = ['get', '1', '2']
    assert_equal("VALUE: 1 2 8\ndatatest\nVALUE: 2 3 15\nanotherdatatest\nEND", @retrieve.get_and_gets(keys), MULTIPLE_VALUE_MESSAGE)
  end

  def test_non_existent_key_multiple_get
    keys = ['get', '3', '4']
    assert_equal("END", @retrieve.get_and_gets(keys), END_MESSAGE)
  end

  def test_non_existent_key_multiple_gets
    keys = ['gets', '3', '4']
    assert_equal("END", @retrieve.get_and_gets(keys), END_MESSAGE)
  end

  def test_normal_multiple_gets
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)
    @store.set(@key2, @flag2, @exp_time2, @size2, @value2, @no_reply)

    keys = ['gets', '1', '2']
    assert_equal("VALUE: 1 2 8 1\ndatatest\nVALUE: 2 3 15 2\nanotherdatatest\nEND", @retrieve.get_and_gets(keys), MULTIPLE_VALUE_MESSAGE)
  end
end