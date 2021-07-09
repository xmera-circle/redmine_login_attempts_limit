# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class InvalidAccountTest < ActiveSupport::TestCase
  def setup
    @plugin = Redmine::Plugin.find(:redmine_login_attempts_limit)
    Setting.define_plugin_setting(@plugin)
    @setting = Setting.plugin_redmine_login_attempts_limit
    @setting[:attempts_limit] = 3
    @setting[:block_minutes]  = 60
  end

  def teardown
    clear_invalid_accounts
    @setting = nil
    @plugin = nil
    Setting.plugin_redmine_login_attempts_limit = {}
  end

  def test_update
    admin = invalid_user_admin
    admin.update
    assert_equal 1, admin.status[:admin][:failed_count]
    assert_kind_of Time, admin.status[:admin][:updated_at]

    admin.update
    assert_equal 2, admin.status[:admin][:failed_count]
  end

  def test_failed_count
    admin = invalid_user_admin
    admin.update
    assert_equal 1, admin.failed_count
    assert_equal 0, invalid_user_bob.failed_count
  end

  def test_attempts_limit
    @setting[:attempts_limit] = 10
    assert_equal 10, invalid_account.attempts_limit

    @setting[:attempts_limit] = 0
    assert_equal 1, invalid_account.attempts_limit
  end

  def test_blocked?
    bob = invalid_user_bob
    3.times { bob.update }
    assert bob.blocked?

    admin = invalid_user_admin
    2.times { admin.update }
    assert_not admin.blocked?
  end

  def test_clear
    bob = invalid_user_bob
    bob.update
    fred = invalid_user_fred
    fred.update
    barney_m = invalid_user_barney_m
    barney_m.update

    fred.clear(:fred)
    assert_not InvalidAccount.status.key? :fred
    assert_equal 2, InvalidAccount.status.count

    bob.clear(:bob)
    barney_m.clear(:barneym)
    assert_empty InvalidAccount.status
  end

  def test_clean_expired
    bob = invalid_user_bob
    bob.update
    fred = invalid_user_fred
    fred.update
    barney_m = invalid_user_barney_m
    barney_m.update

    InvalidAccount.status[:fred][:updated_at] -= (60 * 60) + 1
    InvalidAccount.clean_expired
    assert_not InvalidAccount.status.key? :fred
    assert_equal 2, InvalidAccount.status.count
  end

  private

  def invalid_user_admin
    invalid_account('admin')
  end

  def invalid_user_bob
    invalid_account('Bob') # user1
  end

  def invalid_user_fred
    invalid_account('Fred') # user2
  end

  def invalid_user_barney_m
    invalid_account('BarneyM') # user3
  end

  def invalid_account(username = nil)
    InvalidAccount.new(username)
  end

  def clear_invalid_accounts
    invalid_user_admin.clear
    invalid_user_bob.clear
    invalid_user_fred.clear
    invalid_user_barney_m.clear
  end
end
