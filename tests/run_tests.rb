require 'test/unit'
require_relative 'test_check_data_integrity'
require_relative 'test_set'
require_relative 'test_add'
require_relative 'test_replace'
require_relative 'test_pend'
require_relative 'test_cas'
require_relative 'test_get_and_gets'
require_relative 'test_purge_expired_keys'

suite = Test::Unit::TestSuite.new
suite << TestCheckDataIntegrity.suite
suite << TestSet.suite
suite << TestAdd.suite
suite << TestReplace.suite
suite << TestPend.suite
suite << TestGetAndGets.suite
suite << TestCas.suite
suite << TestPurgeExpiredKeys.suite