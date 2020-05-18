require 'test/unit'
require_relative '../src/storage'
require_relative '../src/memcached'

class TestPurgeExpiredKeys < Test::Unit::TestCase

  KEY1 = ["1"]
  KEY2 = ["2"]

  KEY_MESSAGE = "Key should be returned"
  NIL_MESSAGE = "nil should be returned"
  ARRAY_KEYS_MESSAGE = "Array of keys should be returned"

  def setup
    @mc = Memcached.new
    @store = Storage.new
    @store.initialize_stored_cas_value

    @key = '1'
    @flag = 2
    @exp_time = 1
    @size = 8
    @value = 'datatest'
    @no_reply = false

    @key2 = '2'
    @exp_time2 = 10000

    @multiple_key = %w[1 2]
  end

  # ================
  # |    SINGLE    |
  # ================

  def test_normal_purge_expired_keys_single_key
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    assert_equal(KEY1, @mc.purge_expired_keys(@key), KEY_MESSAGE)
  end

  def test_empty_hash_single_key
    @mc.hash_clear

    assert_equal(nil, @mc.purge_expired_keys(@key), NIL_MESSAGE)
  end

  def test_non_existent_key_single_key
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = '2'
    assert_equal(KEY2, @mc.purge_expired_keys(key), KEY_MESSAGE)
  end

  def test_non_expired_key_single_key
    @store.set(@key, @flag, @exp_time2, @size, @value, @no_reply)

    assert_equal(KEY1, @mc.purge_expired_keys(@key), KEY_MESSAGE)
  end

  # ==================
  # |    MULTIPLE    |
  # ==================

  def test_normal_purge_expired_keys_multiple_key
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)
    @store.set(@key2, @flag, @exp_time, @size, @value, @no_reply)

    assert_equal(@multiple_key, @mc.purge_expired_keys(@multiple_key), ARRAY_KEYS_MESSAGE)
  end

  def test_empty_hash_multiple_key
    @mc.hash_clear

    assert_equal(nil, @mc.purge_expired_keys(@multiple_key), NIL_MESSAGE)
  end

  def test_non_existent_key_multiple_key
    @store.set(@key, @flag, @exp_time, @size, @value, @no_reply)

    key = %w[3 4]
    assert_equal(key, @mc.purge_expired_keys(key), ARRAY_KEYS_MESSAGE)
  end

  def test_non_expired_key_multiple_key
    @store.set(@key, @flag, @exp_time2, @size, @value, @no_reply)
    @store.set(@key2, @flag, @exp_time2, @size, @value, @no_reply)

    assert_equal(@multiple_key, @mc.purge_expired_keys(@multiple_key), ARRAY_KEYS_MESSAGE)
  end

end