require 'test/unit'
require_relative '../src/storage'

class TestCheckDataIntegrity < Test::Unit::TestCase

  OK = "OK"
  OK_MESSAGE = "OK should be returned"
  ERROR = "ERROR"
  ERROR_MESSAGE = "ERROR should be returned"
  CE_BCLF = "CLIENT_ERROR bad command line format"
  CE_BDC = "CLIENT_ERROR bad data chunk"
  CE_MESSAGE = "CLIENT_ERROR should be returned"

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

  def test_normal_check_data_integrity
    assert_equal(OK, @store.check_data_integrity(@key, @flag, @exp_time, @size, @cas_value, @value), OK_MESSAGE)
  end

  # ==============
  # |    FLAG    |
  # ==============

  def test_negative_flag
    flag = '-1'
    assert_equal(CE_BCLF, @store.check_data_integrity(@key, flag, @exp_time, @size, @cas_value, @value), CE_MESSAGE)
  end

  def test_string_flag
    flag = 'data'
    assert_equal(CE_BCLF, @store.check_data_integrity(@key, flag, @exp_time, @size, @cas_value, @value), CE_MESSAGE)
  end

  def test_empty_flag
    flag = nil
    assert_equal(ERROR, @store.check_data_integrity(@key, flag, @exp_time, @size, @cas_value, @value), ERROR_MESSAGE)
  end

  # ==================
  # |    EXP_TIME    |
  # ==================

  def test_negative_exp_time
    exp_time = '-1'
    assert_equal(OK, @store.check_data_integrity(@key, @flag, exp_time, @size, @cas_value, @value), OK_MESSAGE)
  end

  def test_string_exp_time
    exp_time = 'data'
    assert_equal(CE_BCLF, @store.check_data_integrity(@key, @flag, exp_time, @size, @cas_value, @value), CE_MESSAGE)
  end

  def test_empty_exp_time
    exp_time = nil
    assert_equal(ERROR, @store.check_data_integrity(@key, @flag, exp_time, @size, @cas_value, @value), ERROR_MESSAGE)
  end

  # ==============
  # |    SIZE    |
  # ==============

  def test_negative_size
    size = '-1'
    assert_equal(CE_BCLF, @store.check_data_integrity(@key, @flag, @exp_time, size, @cas_value, @value), CE_MESSAGE)
  end

  def test_string_size
    size = 'data'
    assert_equal(CE_BCLF, @store.check_data_integrity(@key, @flag, @exp_time, size, @cas_value, @value), CE_MESSAGE)
  end

  def test_empty_size
    size = nil
    assert_equal(ERROR, @store.check_data_integrity(@key, @flag, @exp_time, size, @cas_value, @value), ERROR_MESSAGE)
  end

  # ===============
  # |    VALUE    |
  # ===============

  def test_wrong_value_size
    value = 'datatest1'
    assert_equal(CE_BDC, @store.check_data_integrity(@key, @flag, @exp_time, @size, @cas_value, value), CE_MESSAGE)
  end
end